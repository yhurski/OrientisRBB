class ApplicationController < ActionController::Base
  helper :all
  layout :none
  #see http://newfather.livejournal.com/151042.html
  protect_from_forgery # :secret => 'ed5c72b58d964b5adaa25ec26a40f5d5'
  skip_before_filter :verify_authenticity_token
  before_filter :session_delay
  before_filter :synch_session_cookies
  before_filter :get_user
  before_filter :set_locale
  before_filter :checking_maintenance_mode
  before_filter :deny_banned_user
  before_filter :fill_board_skin                         
  
  before_filter :get_group_permissions
  before_filter :get_drop_down_menu_data
 
  private

  def get_board_cover session_object=nil
    session ||= session_object
    if User.exists?(session[:user_id])
      return User.find(session[:user_id]).forum_style
    end
    return Configs.get_config('default_style')    
  end
 
  def get_board_styles
    path = "#{RAILS_ROOT}/public/stylesheets/"
    styles_place = Dir.new(path)
    css = []
    styles_place.each{ |entity|
      css << entity if File.stat(path+entity).directory?
      css.delete('..')
      css.delete('.')
    }
    return css
  end 
    
  def get_board_langs
    lang_names = []
    Dir.new(File.join(([RAILS_ROOT, 'config', 'locales', 'defaults']))).each do |file|
      file.downcase!
      lang_names << file.sub(/\.yml/, '') if File.extname(file) == ".yml" 
      lang_names << file.sub(/\.rb/, '') if File.extname(file) == ".rb"
    end
    return lang_names
  end
  
  def language_exists? lang
    Dir.new(File.join(([RAILS_ROOT, 'config', 'locales', 'defaults']))).each do |file|
      return true if ((lang.downcase + '.yml' == file.downcase) || (lang.downcase + '.rb' == file.downcase))
    end
    false
  end

  def  create_forums_optgroup exclude_forum_id = -1, main_forum_title = t(:all_forums), curr_subpartition=0
    parts = Partition.all.each{|partition| partition.drop_denied_subpartitions(@group_permissions)}.sort{|f,s| f.part_pos <=> s.part_pos}
    return nil if parts.empty?
    value = 0;
    unless [exclude_forum_id].include?(0)
      result = "<option value=#{value}>#{main_forum_title}</option>\n"
    else
      result = ""
    end     
    for part in parts
      result << " <optgroup label='#{part.title}'>\n"
      subparts = part.subpartitions or result << "  </optgroup>\n"; next if subparts.empty?
      for subpart in subparts
        unless [exclude_forum_id].include?(subpart.id)
          if subpart.id == curr_subpartition
            result << "     <option value=#{subpart.id} selected=selected>#{subpart.title}</option>\n"
          else  
            result << "     <option value=#{subpart.id}>#{subpart.title}</option>\n"
          end
        end   
      end
      result << " </optgroup>\n"
    end
    return result
  end

  def init_smtp
    ActionMailer::Base.smtp_settings = {
      :address => Configs.find_by_name('smtp_address').value,
      :user_name => Configs.find_by_name('smtp_username').value,
      :password => Configs.find_by_name('smtp_password').value,
      :authentification => :login,
      :enable_starttls_auto => Configs.find_by_name('smtp_ssl').value
    }
  end

  def get_user
    if User.exists?(session[:user_id])
      @usr = User.find(session[:user_id])
    end
  end

  #see ProfileController#around_filter
  def check_user_privileges
    if @usr && @usr.group.g_view_users && (@usr.admin? || @usr.allow_moderation?) && User.exists?(params[:id])
      @privilege_user = @usr
      if ! @usr.admin? && User.exists?(params[:id]) && (User.find(params[:id]).is_moderator? || User.find(params[:id]).admin?)
        yield
        return
      end
      @usr = User.find(params[:id])
      yield
      @usr = @privilege_user
    else
      @privilege_user = @usr
      yield
    end
  end
  
  def check_online3 last_post = nil, last_search = nil
    if @usr
      if Online.exists? ["user_id = ? and name = ? ", @usr.id, @usr.name]
        online_user = Online.find(:first, :conditions => ["user_id = ? and name = ?", @usr.id, @usr.name])
        online_user.last_visit = Time.now.utc
        online_user.prev_url = request.referer#request.url
        online_user.last_post = last_post unless last_post.nil?
        online_user.last_search = last_search unless last_search.nil?
        online_user.save
      else
        #TODO: maybe add last_post and last_search to here
        online_user = Online.create(:user_id => @usr.id, :name => @usr.name, :last_visit => Time.now.utc, :prev_url => request.url)
        session[:last_online_time] = Time.now.utc
      end
      if @usr.last_visit.nil? || ((@usr.last_visit <= Time.now.utc - Configs.get_config('visit_timeout').to_i) && session[:last_visit] && (online_user.last_visit - session[:last_online_time] > Configs.get_config('online_timeout').to_i))
        @usr.update_attribute(:last_visit, online_user.last_visit)
        session[:last_online_time] = online_user.last_visit
      end                         
    else
      if  Online.exists? ["user_id = ? and name = ?", User.get_guest.id, request.remote_addr]
        regenerate_online_record2 ["user_id = ? and name = ?", User.get_guest.id, request.remote_addr], last_post, last_search
      else
        Online.create(:user_id => User.get_guest.id, :name => request.remote_addr, :last_visit => Time.now.utc,
          :prev_url => request.url, :last_post => last_post, :last_search => last_search)
      end  
      return true
    end
  end  
  
  def regenerate_online_record2 condition_array, last_post = nil, last_search = nil, usr_obj = nil
    online_user = Online.find(:first, :conditions => condition_array)
    if online_user
      online_user.last_visit = Time.now.utc
      online_user.prev_url = request.referer#request.url
      online_user.last_post = last_post unless last_post.nil?
      online_user.last_search = last_search unless last_search.nil?
      online_user.save
    end
  end  
   
  #see before_filter
  def remove_online2
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i.seconds
    online_rotten_users  = Online.find(:all, :conditions => ["last_visit < ? or last_visit = ?", online_time_line, online_time_line])
    unless online_rotten_users.empty?
      online_rotten_users.each do |online_user|
        unless online_user.user_id.to_i == 0
          full_record_user = User.find(online_user.user_id)
          full_record_user.update_attribute(:last_visit, online_user.last_visit) if full_record_user && 
            full_record_user.last_visit &&
            (online_user.last_visit - full_record_user.last_visit) > Configs.get_config('visit_timeout').to_i
          full_record_user.update_attribute(:last_post, online_user.last_post) unless online_user.last_post.nil?
          full_record_user.update_attribute(:last_search, online_user.last_search) unless online_user.last_search.nil?
          #TODO: EMAIL LAST TIMEDATE SEND SHOULD WILL BE WRITTEN TO THE USERS TABLE WITHOUT PASS THROUGH ONLINE TABLE
        end
        online_user.delete
      end
    end
  end

  #TODO: remove
  def check_last_visit
    if @usr
      @online_timeout = Time.now.utc
      @online_timeout = Online.find_by_user_object(@usr).last_visit if Online.user_exists?(@usr)
      if @online_timeout - @usr.last_visit >= Configs.get_config('visit_timeout').to_i.seconds
        @usr.update_attribute('last_visit',Time.now.utc)
        User.logout!(session, cookies) unless session[:save_session]
      end
    end
  end

  def set_user_timestamp
    if User.exists? session[:user_id]
      User.update(session[:user_id], :last_visit => Time.now.utc)
    end
  end

  def fill_board_skin
    @forum_style = get_board_cover session
  end

  def save_config_params all_config_records, config_key_arr, params
    @config = Configs.new
    all_config_records.each do |config_record|
      if config_key_arr.include? config_record.name 
        if config_record.value != params[config_record.name]
          config_record.value = params[config_record.name]
          @config.errors.add(config_record.name, config_record.errors.on(config_record.name)) unless config_record.save
        end
        config_key_arr.delete(config_record.name)
      end
    end
  end

  #TODO: refoctor it
  def post_receiver params, session, request, view_name, topic_id = 0, edit_post = false
    if params[:submit] || params[:upload]
      @attach_allowed = true
      if params[:answer_message].blank?
        flash[:empty_post] = t(:before_write_msg)
        session[:post_preview_delete_attach] = nil if session[:post_preview_delete_attach]
        redirect_to :id => params[:id] and return
      end
    end
    if params[:submit]
      if session[:post_preview]
        @new_post =  Post.find(session[:post_preview])
        @new_post.update_post(params, request.remote_addr, session, topic_id, edit_post)
      else
        unless edit_post
          @new_post = Post.save_post(params, request.remote_addr, session, topic_id)
          @new_post.topic.subpartition.num_posts_inc
          @new_post.topic.subpartition.update_attributes(:last_poster => @new_post.poster, :last_post => @new_post.posted, :last_post_id => @new_post.id)
          if @usr
            @usr.numposts_inc
            @usr.set_last_post
          end
        end    
      end
      @attach_max_size_error = AttachFile.save_attach(params, @new_post.id, @group_permissions)
      return if @attach_max_size_error.instance_of?(String)
      session[:post_preview] = nil
    elsif params[:upload] || session[:post_preview_delete_attach]
      unless Configs.get_config('attach_disable_attach').to_bool
        if @group_permissions.admin? || (@group_permissions.attach_allow_upload && @group_permissions.attach_upload_max_size.to_i > 0 && @group_permissions.attach_files_per_post.to_i > 0)                                                   #fixed 20.09.11
          if session[:post_preview]
            @attach_allowed = @group_permissions.attachment_allowed_yet?(Post.find(session[:post_preview]).attach_files.count) 
            @post_incomplete = Post.find(session[:post_preview].to_i)
            @post_incomplete.update_post(params, request.remote_addr, session, topic_id, edit_post)
            @attach_error = Configs.is_allowed_ext(params[:attach][:attach].original_path, @group_permissions) if params[:attach]
            return nil if @attach_error
            @attach_error = AttachFile.save_attach(params, @post_incomplete.id, @group_permissions)
            return nil if @attach_max_size_error.instance_of?(String)
          else
            unless edit_post
              @post_incomplete = Post.save_post(params, request.remote_addr, session, topic_id)
              @post_incomplete.topic.subpartition.num_posts_inc 
              if @usr
                @usr.numposts_inc
                @usr.set_last_post
              end
              session[:post_preview] = @post_incomplete.id
              @attach_error = Configs.is_allowed_ext(params[:attach][:attach].original_path, @group_permission) if params[:attach]
              return nil if @attach_error
              @attach_max_size_error = AttachFile.save_attach(params, @post_incomplete.id, @group_permissions)
              return nil if @attach_max_size_error.instance_of?(String)
            end    
          end
        else
          @attach_allowed = false
          @post_incomplete = Post.find(session[:post_preview].to_i)
        end
      end
    else
      unless edit_post 
        session[:post_preview] = session[:post_preview_delete_attach] = nil
      end   
    end
    if session[:post_preview]
      @attach_allowed = @group_permissions.attachment_allowed_yet?(Post.find(session[:post_preview]).attach_files.count)
    else
      @attach_allowed = true  
    end
    @new_post
  end

  #TODO: refactor it
  def topic_receiver params, session, request, edit_topic = false
    if params[:submit] || params[:upload]
      if params[:topic_title].blank?
        flash[:empty_post] = t(:before_write_msg)
        redirect_to :id => params[:id] and return
      end  
    end
    if params[:upload] || params[:submit]
      if session[:topic_preview]
        @topic =  Topic.find(session[:topic_preview])
        @topic.update_attributes(:title => params[:topic_title])
        return unless @topic.errors.empty?
        post_receiver params, session, request, 'view_posts', @topic.id, edit_topic
        if @new_post
          if edit_topic
            return
          else
            @topic.update_attributes(:first_post_id => @new_post.id, :last_post_id => @new_post.id, :last_post => Time.now.utc)
          end                                               
        else
          return
        end
      else
        unless edit_topic
          @topic = Topic.save_topic(params, session)
          return unless @topic.errors.empty?
          session[:topic_preview] = @topic.id
          post_receiver params, session, request, 'view_topics', @topic.id
          if @new_post
            @topic.update_attributes(:first_post_id => @new_post.id, :last_post_id => @new_post.id, :last_post => Time.now.utc)
            @topic.subpartition.new_topic_inc
            if @usr
              @usr.numposts_inc
              @usr.set_last_post
            end
          else
            return
          end
        end    
      end
    end
    unless edit_topic
      session[:topic_preview] = nil if params[:submit]
    end    
    @new_post
  end

  #see ForumController#after_filter
  def destroy_bogus_topic
    unless session[:topic_preview]
      Topic.destroy(session[:topic_preview]) if session[:topic_preview].to_i > 0
    end
  end

  def get_group_permissions
    if @usr
      @group_permissions = @usr.group
    else
      @group_permissions = Group.get_guest
    end    
  end
  
  def checking_maintenance_mode
    if Configs.get_config('enable_maintenance').to_bool
      unless ! @usr.nil? and @usr.group.admin?
        render :action => '../forum/maintenance', :layout => false and return
      end
    end
  end
    
  def deny_banned_user
    if (@usr.blank? && Ban.find_by_ip(request.remote_addr)) || (@usr && Ban.find_by_username(@usr.name))
      flash[:permission_message] = t(:you_banned)
      unless Configs.get_config('admin_email').blank?
        flash[:permission_message] << (t(:msg) + Configs.get_config('admin_email') + t(:gr_sign) + Configs.get_config('admin_email') + t(:closed_a))
      end
      redirect_to :controller => 'forum', :action => 'message' and return
    end
  end
    
  def session_delay
    unless session[:user_id]
      if cookies[:stay_with_me_orientis]
        if session_data = Session.find_by_session_id(cookies[:stay_with_me_orientis])
          if session_hash =  ActiveRecord::SessionStore::Session.unmarshal(session_data.data)
            if session_hash.has_key? :user_id
              session[:user_id], session[:save_session] = session_hash[:user_id], true
              Session.find_by_session_id(cookies[:stay_with_me_orientis]).delete
            end  
          end    
        end
      end
    end
  end  
  
  def synch_session_cookies
    if cookies.has_key?('orientisrbb_session') && cookies.has_key?('stay_with_me_orientis') && cookies[:orientisrbb_session] != cookies[:stay_with_me_orientis]
      cookies[:stay_with_me_orientis] = {:value => cookies[:orientisrbb_session], :expires => Time.now.utc + 1.year} 
    end
  end  
  
  def redirecting title, link
    @redirect_timeout = Configs.get_config('redirect_timeout').to_i
    @redir_link = link || '/forum/main'
    if @redirect_timeout > 0
      @title = title
      render('/forum/redirecting', :layout => false) and return
    else
      redirect_to @redir_link and return
    end
  end
  
  def put_last_page_in_session
    session[:last_page] = request.url
  end
  
  def get_drop_down_menu_data
    if Configs.get_config('allow_jumpmenu').to_bool
      @forum_list = if ('postreply' == params[:action] || 'view_posts' == params[:action]) && params[:id] && Topic.exists?(params[:id])
        create_forums_optgroup -1, t(:main_forum), Topic.find(params[:id]).subpartition.id
      elsif ('view_topics' == params[:action] || 'new_topic' == params[:action]) && params[:id] && Subpartition.exists?(params[:id])
        create_forums_optgroup -1, t(:main_forum), params[:id].to_i
      else
        create_forums_optgroup -1, t(:main_forum)
      end
    end
  end
  
  def set_locale
    I18n.default_locale = if (@usr && language_exists?(@usr.forum_lang))
      @usr.forum_lang
    else
      Configs.get_config('default_lang')
    end
  end
end