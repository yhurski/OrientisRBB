class ForumController < ApplicationController
  layout 'forum', :except => ['redirecting']

  skip_before_filter :deny_banned_user, :only => ['message']
  before_filter :init_smtp, :only => "regist" 

  before_filter :fill_board_skin
  after_filter :set_user_timestamp, :except => ['login', 'regist']
  
  before_filter :post_flood_timeout_check, :only => ['view_posts', 'postreply', 'new_topic', 'report']
  around_filter :put_post_time, :only => ['view_posts', 'postreply', 'new_topic', 'report']
  
  before_filter :check_online3, :except => ['login']
  before_filter :remove_online2
  
  after_filter :put_last_page_in_session, :only => ['main', 'view_topics', 'view_posts', 'users_list', 'profile', 'show_new_messages']
  before_filter :read_forum_permission, :except => ['login', 'logout', 'regist', 'profile', 'users_list', 'message']
  before_filter :view_users_permission, :only => ['users_list']
  before_filter :search_users_permission, :only => ['users_list']
  before_filter :post_replies_permission, :only => ['postreply']
  before_filter :edit_posts_permission, :only => ['edit_post']
  before_filter :delete_posts_permission, :only => ['delete_post']
  before_filter :delete_topics_permission, :only => ['delete_topic']
  before_filter :alien_profile_view_permission, :only => ['profile']
  before_filter :new_user_registration_permission, :only => ['regist']

  before_filter :read_subpartition_permission, :only => ['view_topics', 'view_posts', 'new_topic', 'view_posts']
  before_filter :post_topic_subpartition_permission, :only => ['new_topic']
  before_filter :new_post_subpartition_permission, :only => ['postreply', 'view_posts']
  before_filter :allow_attach_permission, :only => ['send_attach', 'remove_attach', 'drop_attach']
  before_filter :send_attach_permission, :only => ['send_attach']
  before_filter :delete_attach_permission, :only => ['remove_attach']
  before_filter :write_to_closed_topic_permission, :only => ['postreply', 'view_posts']
  before_filter :allow_jump_menu_navigation, :only => ['go_to_forum_page']
  before_filter :filter_by_sorting_column, :only => ['users_list']
  
  before_filter :skip_login_page, :only => ['login']
  before_filter :skip_remind_page, :only => ['remind']
  before_filter :skip_registration_page, :only => ['regist', 'rules_confirmation']
  
  before_filter :check_registration_rules, :only => ['regist']
  before_filter :clear_postreply_session, :except => ['login', 'logout', 'regist', 'message', 'postreply', 'new_topic', 'drop_attach', 'edit_topic', 'edit_post']
  before_filter :only_login_user_permissions, :only => ['send_email', 'report', 'show_new_messages', 'check_new_messages']

  def main
    @partitions = Partition.all.each{|partition| partition.drop_denied_subpartitions(@group_permissions)}.sort{|first, second| first.part_pos <=> second.part_pos}       
  end

  def view_topics
    unless Subpartition.exists?(params[:id])
      redirect_to_info_page t(:not_exists)
      return
    end
    @subpart = Subpartition.find(params[:id])
    @topics = Topic.paginate :conditions => ["subpartition_id = ?", params[:id]], :page => params[:page], :order => 'sticky desc,last_post desc', :per_page => (@usr ? @usr.pagination_topics_amount : User.get_guest.pagination_topics_amount)#per_page
  end
  
  def view_posts
    unless Topic.exists?(params[:id])
      redirect_to_info_page t(:not_exists)
      return
    end
    params[:id] = Topic.find(params[:id]).moved_to if Topic.find(params[:id]).moved_to.to_i > 0 && Topic.exists?(Topic.find(params[:id]).moved_to)
    @topic = Topic.find(params[:id])
    @post = Post.paginate :conditions => ["topic_id = ?", params[:id]], :page => params[:page], :order => 'posted asc', :per_page => (@usr ? @usr.pagination_posts_amount : User.get_guest.pagination_posts_amount)
    @postnumber =  Configs.get_config('postsperpage').to_i * (params[:page].to_i - 1)
    Topic.find(params[:id]).increment!(:num_views) if Configs.get_config('show_views').to_bool
    if params[:submit]
      @new_post = Post.save_post params, request.remote_addr, session
      if @new_post.errors.blank?
        @new_post.update_post_dependent
        @usr.numposts_inc
        @usr.set_last_post       
        redirecting t(:redir), session[:last_page]
        return
      end
      redirect_to :action => 'view_posts' and return
    end
    @new_post
  end

  def new_topic
    @attach_allowed = true
    topic_receiver params, session, request
    unless @new_post.nil?
      redirecting t(:redir), session[:last_page]
      return
    end    
  end
    
  def edit_topic
    @attach_allowed = true
    session[:topic_preview] ||= params[:id]
    params[:upload] = 'upload' unless params[:submit]
    params[:topic_title] ||= Topic.find(params[:id]).title
    session[:post_preview] ||= params[:post]
    params[:answer_message] ||= Post.find(params[:post]).message
    topic_receiver params, session, request, true
    if @new_post
      session[:topic_preview] = nil
      session[:post_preview] = session[:post_preview_delete_attach] = nil
      redirecting t(:redir), "/forum/view_posts/#{@topic.id}"
    else
      render :action => 'new_topic'
    end
    return
  end
    
  def edit_post
    session[:post_preview] ||= params[:post]
    params[:upload] = 'upload' unless params[:submit]
    params[:answer_message] ||= Post.find(params[:post]).message
    session[:edit_post] = true
    post_receiver params, session, request, 'view_posts', 0, true
    if @new_post
      session[:post_preview] = session[:post_preview_delete_attach] = nil
      redirecting t(:redir), session[:last_page]
      return
    end
  end  
    
  def delete_topic
    if Topic.exists? params[:id]
      @topic = Topic.find(params[:id])
      if params[:delete]
        subpartition_id = @topic.subpartition.id
        @topic.destroy
        redirecting t(:redir), "/forum/view_topics/#{subpartition_id}"
      end
      if params[:cancel]
        redirect_to :action => 'view_posts', :id => @topic.id and return
      end
    else
      redirect_to_info_page t(:not_exists)
      return
    end
  end
  
  def delete_post
    if Post.exists?(params[:id])
      @dropped_post = Post.find(params[:id])
      if params[:commit] == t(:remove) && params[:remove_acceptance]
        @dropped_post.topic.decrement! :num_replies
        @dropped_post.topic.subpartition.decrement! :num_posts
        @dropped_post.destroy
        redirecting t(:redir), session[:last_page]
        return
      end
      if params[:commit]
        redirecting t(:canc), session[:last_page]
        return
      end
    else
      redirect_to_info_page t(:not_exists)
      return
    end
  end  
    
  def login
    if params[:user]
      user = User.find_by_name(params[:user][:username])
      user &&= User.find_by_passwd( User.get_md5_passwd_hash(params[:user][:password], user.salt) )
      unless user.nil?
        reset_session
        session[:user_id] = user.id
        if params[:user][:save_session]
          session[:save_session] = true               
          cookies[:stay_with_me_orientis] = {:value => cookies[:orientisrbb_session], :expires => Time.now.utc + 1.year}
        end    
        this_user = Online.find_by_ip(request.remote_addr)
        if  this_user && this_user.prev_url
          redirecting t(:redir), this_user.prev_url
        else
          redirecting t(:redir), '/forum/main'
        end
        user.update_attribute(:remind_pass_sended, false) if user.remind_pass_sended
        return
      end
      @login_error = t(:not_exists)
    end
  end
  
  def logout
    online_user = Online.find_by_user_object(@usr)
    if online_user
      @usr.update_attribute(:last_search, online_user.last_search) if online_user.last_search
      @usr.update_attribute(:last_post, online_user.last_post) if online_user.last_post
      @usr.update_attribute(:last_visit, online_user.last_visit) if (online_user.last_visit - @usr.last_visit) > Configs.get_config('visit_timeout').to_i
    end
    User.logout! session, cookies
    redirecting t(:redir), '/forum/main'
    return
  end
    
  def go_to_forum_page
    if params[:forum]
      if Subpartition.exists?(params[:forum][:id])
        redirect_to :controller => 'forum', :action => 'view_topics', :id => params[:forum][:id] and return
      else
        redirect_to :controller => 'forum', :action => 'main'
      end
      return
    end
    redirect_to :action => 'main' and return  
  end

  def regist
    @user = User.new
    if params[:users]
      User.with_captcha_validation do
        @user = User.create_registration_data(params, request.remote_addr)
        if @user.errors.empty?
          process_registration
        end
      end
    end
  end
  
  def rules_confirmation
    if params[:agree] && params[:agree_rules]
      redirect_to :action => 'regist', :agree => params[:agree], :agree_rules => params[:agree_rules] and return
    elsif params[:agree] || params[:cancel]
      redirect_to :action => 'main' and return
    end
  end

  def remind
    if params[:user]
      remind_password params
    end
  end

  #TODO: make html sanitization in view
  def profile
    if params[:id] && User.exists?(params[:id])
      @prof = User.find(params[:id])
    else
      redirect_to_info_page t(:redir)
      return
    end
  end
      
  #TODO: anonym may send email. it's dangerous
  def send_email
    if User.exists? params[:id]
      @email_to_usr = User.find(params[:id])
      if params[:commit]
        if @sending_res = profile_mail_sending(params, @email_to_usr)
          return if @sending_res.kind_of? Hash
          redirecting(t(:email_redir), session[:last_page])
        else
          redirect_to_info_page t(:email_error)
        end
        return
      end
    else
      redirect_to_info_page
    end
  end
  
  def show_profile_posts
    if User.exists? params[:id]
      @user_profile_posts = Post.find(:all, :conditions => ["poster_id = ?", params[:id]], :order => 'posted desc')
    else
      redirect_to_info_page
    end
  end

  #TODO: anonym may use reports
  def report
    if Post.exists?(params[:id])
      if params[:reports]
        @new_report = Report.create_new(params, @usr)
        if @new_report.errors.empty?
          unless Configs.get_config('mailing_list').blank?
            Configs.get_config('mailing_list').split(',').each do |email|
              ReportMailer.deliver_email(@new_report.user.name, email.strip, @new_report, request.env['HTTP_HOST'])
            end
          end
          redirecting t(:redir), session[:last_page]
          return
        end
      end
    else
      redirect_to_info_page
    end
  end

  def postreply
    if Topic.exists?(params[:id])
      post_receiver params, session, request, 'view_posts'
      @post_incomplete = Post.find(session[:post_preview]) if (session[:post_preview] && session[:post_preview_delete_attach])
      if @new_post && @new_post.errors.empty?
        @new_post.topic.update_attributes(:last_poster => @new_post.poster, :last_post_id => @new_post.id, :last_post => @new_post.posted)
        @new_post.topic.increment!(:num_replies)
        redirecting t(:redir), session[:last_page]
        return
      end
    else
      redirect_to_info_page
    end
  end

  def drop_attach
    if Post.exists?(session[:post_preview])
      @post_incomplete = Post.find(session[:post_preview])
      unless session[:post_preview] && @post_incomplete.user == @usr && @post_incomplete.attach_files.exists?(params[:id])
        flash[:drop_attach_error] = t(:auth_error)
        unless session[:post_preview]
          flash[:drop_attach_error] = t(:attach_error)
        end
        session[:post_preview_delete_attach] = true
        redirect_to :action => 'postreply', :id => @post_incomplete.topic.id and return
      end
      @post_incomplete.attach_files.find(params[:id]).destroy
      session[:post_preview_delete_attach] = true
      redirecting t(:redir), "/forum/postreply/#{@post_incomplete.topic.id}"
    else
      redirect_to_info_page
    end
  end

  def send_attach
    if AttachFile.exists?(params[:attach_id])
      attach_file = AttachFile.find(params[:attach_id])
      send_file attach_file.attach.path, :disposition => 'attachment', :type => attach_file.attach_content_type
      attach_file.increment! :download_counter
    else
      redirect_to_info_page
    end
  end
   
  def remove_attach
    if AttachFile.exists?(params[:attach_id])
      @attach_file = AttachFile.find(params[:attach_id])
      if params[:commit] == 'Remove' && @attach_file.destroy
        redirecting t(:redir), session[:last_page]
        return
      end
      if params[:commit]
        redirecting t(:redir), session[:last_page]
        return
      end
    else
      redirect_to_info_page
    end
  end

  #show list of all registered users
  def users_list
    @users_list = User.order_by_asc('name').find(:all, :conditions => ["group_id <> ?", Group.get_guest.id])
    if params[:users]
      @users_list = User.get_user_list params
    end
  end

  #TODO: prevent from anonym
  def show_new_messages
    @topics = Topic.paginate :conditions => ["last_post > ?", @usr.last_visit], :page => params[:page], :per_page => Configs.get_config('topperpage'), :order => 'last_post DESC'
    if @topics.empty?
      redirect_to_info_page t(:redir)
      return 
    end
  end

  def check_new_messages
    @usr.update_attribute(:last_visit, Time.now.utc)
    if Online.user_exists? @usr
      redirect_to Online.find_by_user_object(@usr).prev_url
    end
  end

  def message
    flash.keep
  end

private

  def redirect_to_info_page message = t(:def_msg)
    flash[:permission_message] = message
    redirect_to :action => 'message'
  end

  def read_forum_permission
    unless @group_permissions.g_read_board
      redirect_to_info_page t(:perm_msg)
    end
  end

  def view_users_permission
    unless @group_permissions.g_view_users
      redirect_to_info_page
    end
  end

  def search_users_permission
    unless @group_permissions.g_search_users
      params[:users][:name] = '%' if (params && params[:users] && params[:users][:name])
    end
  end

  def post_replies_permission
    unless @group_permissions.g_post_replies || (Topic.exists?(params[:id]) && Topic.find(params[:id]).subpartition.forum_perms.find_by_group_id(@group_permissions.id).post_replies)
      redirect_to_info_page
    end
  end

  def edit_posts_permission
    unless (Post.exists?(params[:post]) || Post.exists?(session[:post_preview])) && (@group_permissions.admin? || (@group_permissions.moderator? && @group_permissions.subpartitions.map(&:id).include?(Post.find(params[:id]).topic.subpartition.id)) || (@usr && Post.find(params[:post]).user == @usr && @group_permissions.g_edit_posts))
      redirect_to_info_page
    end
  end

  def delete_posts_permission
    unless Post.exists?(params[:id]) && (@group_permissions.admin? || (@group_permissions.moderator? && @group_permissions.subpartitions.map(&:id).include?(Post.find(params[:id]).topic.subpartition.id)) || (@usr && Post.find(params[:id]).user == @usr && @group_permissions.g_delete_posts))
      redirect_to_info_page
    end
  end

  def delete_topics_permission
    unless Topic.exists?(params[:id]) && (@group_permissions.admin? || (@group_permissions.moderator? && @group_permissions.subpartitions.map(&:id).include?(Topic.find(params[:id]).subpartition.id)) || (@usr && Topic.find(params[:id]).user == @usr && @group_permissions.g_delete_topics))
      redirect_to_info_page
    end
  end

  def read_subpartition_permission
    id = false
    if params[:action] == 'view_posts'
      id = Topic.find(params[:id]).subpartition.id if Topic.exists?(params[:id])
    else
      id = params[:id] if Subpartition.exists?(params[:id])
    end
    unless id && Group.find(  Group.get_user_group_id(@usr) ).forum_perms.find_by_subpartition_id(id).read_forum
      redirect_to_info_page t(:perms_msg)
    end
  end

  def post_topic_subpartition_permission
    unless Group.find(  Group.get_user_group_id(@usr) ).forum_perms.find_by_subpartition_id(params[:id]).post_topics
      redirect_to_info_page t(:perms_msg)
    end
  end

  def new_post_subpartition_permission
    if params[:action] == 'postreply' or (params[:action] == 'view_posts' and params[:submit])
      return nil unless Topic.exists?(params[:id])
      unless Group.find(  Group.get_user_group_id(@usr) ).forum_perms.find_by_subpartition_id(Topic.find(params[:id]).subpartition.id).post_replies
        redirect_to_info_page t(:perms_msg)
      end
      if params[:action] == 'view_posts' and ! Configs.get_config('show_quickpost').to_bool
        redirect_to_info_page t(:perms_msg)
      end
    end
  end

  def allow_jump_menu_navigation
    unless Configs.get_config('allow_jumpmenu').to_bool
      redirect_to :action => 'main' and return
    end
  end

  def filter_by_sorting_column
    unless Configs.get_config('allow_postcount').to_bool
      if params[:users] && ! ['name', 'regdatetime'].include?(params[:users][:sorting])
        redirect_to_info_page t(:wrong)
      end
    end
  end
  
  def skip_login_page
    if defined? @usr
      redirect_to_info_page t(:logined)
    end
  end

  def skip_remind_page
    if defined? @usr
      redirect_to_info_page
    end
  end
  
  def skip_registration_page
    if defined? @usr
      redirect_to_info_page t(:perms)
    end
  end
    
  def put_post_time
    if @usr
      report_count = @usr.reports.size
      post_count = @usr.posts.size
      yield
      if @usr.posts.size > post_count || @usr.reports.size > report_count
        check_online3(Time.now.utc, nil)
      end
    else
      if params[:anonym_name]
        post_count = Post.find_all_by_poster(params[:anonym_name]).size
      end
      yield
      check_online3(Time.now.utc) if (params[:anonym_name] && Post.find_all_by_poster(params[:anonym_name]).size > post_count)
    end	  
  end
    
  def post_flood_timeout_check      
    if params[:submit] || params[:commit]
      if @usr
        if online_user = Online.find_by_user_object(@usr)
          last_post_time = online_user.last_post
        else
          last_post_time = @usr.last_post
        end
      else
        last_post_time = online_user.last_post if online_user = Online.find(:first, :conditions => ["user_id = ? and name = ?", User.get_guest.id, request.remote_addr])
      end
      if last_post_time && (last_post_time + @group_permissions.g_post_flood.to_i) > Time.now.utc
        redirect_to_info_page (t(:at_least) + @group_permissions.g_post_flood.to_s + t(:seconds))  and return
      end
    end
  end

  def check_registration_rules
    if Configs.get_config('use_rules').to_bool
      unless params[:agree] && params[:agree_rules]
        redirect_to :action => 'rules_confirmation' and return
      end
    end
  end
    
  def profile_mail_sending(params, to_user)
    errors = {}
    errors[:missing_subj] = t(:subj_empty) if params[:subj].nil?
    errors[:missing_body] = t(:body_empty) if params[:body].nil?
    return errors unless errors.empty?
    if ProfileMail.deliver_email(to_user.email, @usr.email, params[:subj], params[:body], to_user.timedate_convert(Time.now.utc))
      return true
    else
      return false
    end
  end
    
  def alien_profile_view_permission
    unless @group_permissions.g_view_users
      redirect_to_info_page
    end
  end
    
  def new_user_registration_permission
    unless Configs.get_config('allow_registration').to_bool
      redirect_to_info_page
    end
  end
    
  def clear_postreply_session
    if ! session[:edit_post]
      if session[:post_preview] && Post.exists?(session[:post_preview])
        Post.find(session[:post_preview]).attach_files.destroy_all
        Post.destroy session[:post_preview]
      end
      session[:post_preview] = session[:post_preview_delete_attach] = nil
    elsif session[:edit_post]
      session[:edit_post] = session[:post_preview] = nil
    end
  end
  
  def send_attach_permission
    unless @group_permissions.attach_allow_download
      redirect_to_info_page
    end
  end
  
  def delete_attach_permission
    if ! @group_permissions.admin? && ! (@usr && @group_permissions.attach_allow_delete_own && AttachFile.find(params[:attach_id]).post.user == @usr) &&
        ! (@usr && @usr.is_moderator? && @usr.subpartitions.map(&:id).include?(AttachFile.find(params[:attach_id]).post.topic.subpartition.id))
      redirect_to_info_page                                                           
    end
  end

  def allow_attach_permission
    if Configs.get_config('attach_disable_attach').to_bool
      redirect_to_info_page
    end
  end
    
  def write_to_closed_topic_permission
    if params[:submit] && params[:id] && Topic.exists?(params[:id]) && Topic.find(params[:id]).closed
      if @usr && !@usr.admin? && ! (@usr.is_moderator? && @usr.subpartitions.map(&:id).include?(Topic.find(params[:id]).subpartition.id))
        redirect_to_info_page
      end
    end  
  end
    
  def process_registration
    if Configs.get_config('verify_registration').to_bool
      @res = RegistrationMailer.deliver_confirm(@user.email, request.env['HTTP_HOST'], request.env['HTTP_HOST'], params[:users][:name], @user.plain_password)
      redirect_to_info_page t(:thx)
      return
    else
      session[:user_id] = @user.id
      redirecting t(:redir), '/forum/main'
      return
    end
  end
  
  def remind_password params
    forgotten_user = User.find(:first, :conditions => ['name = ? and email = ?', params[:user][:name], params[:user][:email]])
    if forgotten_user && ! forgotten_user.remind_pass_sended
      new_passwd = Password.pronounceable
      RemindPasswordMailer.deliver_email(forgotten_user.email,   request.env['HTTP_HOST'], request.env['HTTP_HOST']+'/forum', new_passwd)
      forgotten_user.update_attribute(:passwd, User.get_md5_passwd_hash(new_passwd, forgotten_user.salt))
      forgotten_user.update_attribute(:remind_pass_sended, true)
      redirect_to_info_page t(:redir)
      return
    else
      if forgotten_user.nil?
        @remind_pass_error = t(:not_exists)
        return
      elsif forgotten_user.remind_pass_sended
        @remind_pass_error = t(:password_changed)
        return
      end
      @remind_pass_error = t(:email_sended) if forgotten_user. remind_pass_sended
    end
  end
  
  def only_login_user_permissions
    unless @usr
      redirect_to_info_page
    end
  end
end
