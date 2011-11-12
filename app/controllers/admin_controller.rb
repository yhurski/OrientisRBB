class AdminController < ApplicationController
  before_filter :get_user
  before_filter :check_user_privileges, :except => ['message']
  before_filter :check_moderator_privileges, :except => ['info', 'search', 'reports', 'bans', 'message']
  before_filter :ban_moderation_permission, :only => ['bans']
  after_filter :put_last_page_in_session

  def manage_subpartitions
    @partitions = Partition.all
    if params[:add]
      @new_subpartition = Subpartition.create(params[:add])
      @new_subpartition.set_default_perms if (@new_subpartition && @new_subpartition.id.to_bool)
      if @new_subpartition.errors.empty?
        redirecting t(:redir), '/admin/manage_subpartitions'
        return
      end
    end
  end

  def manage_partitions
    @partitions = Partition.all
    if params[:add]
      @result_part = Partition.create(params[:add])
    end
    if params[:delete]
      @result_part = Partition.destroy(params[:delete][:partition])
    end
    if params[:update] && params[:id]
      @result_part = Partition.update(params[:id], params[:update]) if Partition.exists?(params[:id])
    end
    if @result_part && @result_part.errors.empty?
      redirecting t(:redir), '/admin/manage_partitions'
      return
    end
  end

  def edit_subpartitions
    if params[:update] && Subpartition.exists?(params[:id])
      @upd_subp = Subpartition.update(params[:id], params[:update])
      if params[:permissions]
        ForumPerm.save_groups_permissions(params[:permissions], params[:id])
      end
      if @upd_subp.errors.empty?
        redirecting t(:redir), '/admin/manage_subpartitions'
        return
      end
    end
    @subpartition = Subpartition.find(params[:id])
    @partitions = Partition.all
    @groups = Group.find(:all, :conditions => ["id <> ?", Group.get_admin.id])
  end
  
  def drop_subpartition
    if Subpartition.exists?(params[:id])
      Subpartition.destroy(params[:id])
      redirecting t(:redir), '/admin/manage_subpartitions'
      return
    else
      redirect_to_error_page t(:not_exists)
    end
  end

  def setup            
    par_arr = get_setup_page_params
    @all_config_records = Configs.all
    if params[:commit]
      save_config_params @all_config_records, par_arr,  params   
      if @config.valid?
        redirecting t(:redir), session[:last_page]
        return             
      end
    end
    @board_styles = get_board_styles
    @board_langs = get_board_langs
  end

  def features
    par_arr = get_features_page_params
    @all_config_records = Configs.all
    if params[:commit]
      save_config_params @all_config_records, par_arr,  params    
      if @config.errors.empty?
        redirecting t(:redir), session[:last_page]
        return             
      end
    end
  end
  
  def notices
    if params[:notices]
      Configs.update_notices(params[:notices][:allow_notice], params[:notices][:notice_title], params[:notices][:notice_message])
      redirecting t(:redir), session[:last_page]
      return
    end
  end
  
  def email
    par_arr = get_email_page_params
    @all_config_records = Configs.all
    if params[:commit]
      save_config_params @all_config_records, par_arr,  params    
      if @config.errors.empty?
        redirecting t(:redir), session[:last_page]
        return             
      end
    end
  end
  
  def registration
    par_arr = get_registration_page_params
    @all_config_records = Configs.all
    if params[:commit]
      save_config_params @all_config_records, par_arr,  params    
      if @config.errors.empty?
        redirecting t(:redir), session[:last_page]
        return             
      end
    end
  end
  
  def censoring
    if params[:censors]
      if params[:submit] == 'Update'
        if Censor.exists?(params[:id])
          Censor.update(params[:id], params[:censors]) 
          redirecting t(:r_updated), session[:last_page]
          return
        end
      elsif params[:submit] == 'Remove'
        if Censor.exists?(params[:id])
          begin
            Censor.destroy(params[:id])
            redirecting t(:r_del), session[:last_page]
            return
          rescue => ex
            render :text => ex.message
            return
          end
        end
      else
        Censor.create(params[:censors])
        redirecting t(:r_created), session[:last_page]
        return
      end     
      redirect_to :action => 'censoring'
    end
    @censor = Censor.new
    @censorsAll = Censor.all
  end
  
  def attach
    if params[:act] == 'save'
      flash[:no_icon_file] = Configs.save_attach_configuration(params)
      redirecting t(:redir), session[:last_page]
      return
    end
    @attach = Configs.find(:all, :conditions => ["name LIKE ?",  "attach%"]).hashing_by('name')
    @rpath = Configs.get_config('attach_icon_folder')
    @icons = Configs.get_icon_collection
    @missing_icons = Configs.get_not_avail_icons
    @save_attach_conf_message = flash[:no_icon_file]
  end
  
  def search
    @order_by = {t(:username) => "name", t(:email) => "email", t(:posts) => "numposts", t(:last_post) => "last_post", t(:registered) => "regdatetime"}
    if params[:act] == 'search'
      @searched_usrs = (User.perform_full_search(params, @usr) || [])
      if @searched_usrs.instance_of?(Hash)
        @error_hash = @searched_usrs
        return
      end
      render :action => 'search_results'
      return           
    end
  end
  
  def user_ip
    if params[:id] && User.exists?(params[:id])
      @user_ip_posts = Post.find(:all, :conditions => ['poster_id = ?', params[:id]], :select => 'MAX(posted) as max_posted, COUNT(posted) as count_posted_ip, poster_ip', :group => 'poster_ip')
    elsif params[:ip] && ! (params[:ip] =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/).nil?
      @searched_usrs = User.find_by_sql("select id,group_id,name,numposts,email,title from users where id in (select poster_id from posts where poster_ip = '#{params[:ip]}' group by poster);")
      render :action => 'search_results' and return
    end
  end
  
  def show_host
    if params[:ip] && ! (params[:ip] =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/).nil?
      begin
        @hostname = Resolv.new.getname(params[:ip])
      rescue Exception
        @message = t(:bad_request)
      end
    end
  end
  
  def user_posts
    if User.exists?(params[:id])
      @user_posts = Post.paginate_by_poster_id params[:id], :page => params[:page], :per_page => @usr.pagination_posts_amount, :order => 'posted desc'
    else
      redirect_to_error_page t(:redir)
    end
  end
  
  #add, edit, remove groups of users
  def groups
    save_default_group(params)
    delete_group(params)
  end
  
  def addgroup
    if params[:group]
      new_grp = Group.create(params[:group])
      Subpartition.all.each{|subpart| new_grp.forum_perms.create(:subpartition_id => subpart.id, :read_forum => new_grp.g_read_board, :post_replies => new_grp.g_post_replies, :post_topics => new_grp.g_post_topics)}
      redirecting t(:r_created), '/admin/groups'
      return
    else
      if Group.exists?(params[:parent_group])
        @gr = Group.find(params[:parent_group])
        @gr.name = @gr.title_name = ""
        @type = 2 unless @gr.is_moder_in_group
        render  'add_group'
      else
        redirect_to_error_page t(:redir)
      end
    end
  end
 
  def editgroup
    if Group.exists?(params[:ident])
      @gr = Group.find(params[:ident])
      @type = if @gr.admin? then 0 elsif @gr.guest? then 1 elsif ((Configs.get_config('default_group').to_i == @gr.id) || ! @gr.is_moder_in_group) then 2 end
      #save new group or update old
      if params[:group]
        if params[:group][:id]
          if @gr.id == params[:group][:id].to_i
            @gr.update_attributes(params[:group])
            @gr.forum_perms.each{|perm| perm.update_attributes(:read_forum => params[:group][:g_read_board],:post_replies => params[:group][:g_post_replies], :post_topics => params[:group][:g_post_topics])}
          end
        else
          Group.create(params[:group])
        end
        return unless @gr.errors.empty?
        redirecting t(:r_edited), '/admin/groups'
        return
      end
      render 'add_group'
      return
    else
      redirect_to_error_page t(:redir)
    end
  end
  
  #add, change, remove user rank
  def ranks
    if params[:ranks]
      if params[:submit] == t(:update)
        if Rank.exists?(params[:id])
          Rank.update(params[:id], params[:ranks]) 
        end
      elsif params[:submit] == t(:remove)
        if Rank.exists?(params[:id])
          begin
            Rank.destroy(params[:id])
          rescue => ex
            render :text => ex.message
            return
          end
        end
      else
        Rank.create(params[:ranks])
      end     
      redirecting t(:redir), session[:last_page]
      return
    end
    @rank = Rank.new
    @ranks = Rank.all
  end

  #TODO: refactor it
  def bans
    if params[:act] == 'add' || params[:act] == 'edit'
      if params[:act] == 'add'
        if params[:id] && User.exists?(params[:id])
          ban_user = User.find(params[:id])
        elsif params[:banname] && User.exists?(['name = ?', params[:banname]])
          ban_user = User.find_by_name(params[:banname])
        end      
        if ban_user
          @bans = Ban.new(:username => ban_user.name, :email => ban_user.email, :ip => ban_user.registration_ip, :ban_creator => @usr.id)
        end                                                
      else
        if params[:id] && Ban.exists?(params[:id])
          @bans = Ban.find(params[:id])
        end
      end     
      render 'add_edit_ban' and return
    end 
      
    if params[:act] == 'save'
      params[:bans][:ban_creator] = @usr.id
      params[:bans][:expire] = @usr.user_date_to_utc(params[:bans][:expire])
      if @bans = Ban.find_by_username(params[:bans][:username]) 
        @bans = Ban.update(@bans.id, params[:bans])
      else
        @bans = Ban.create(params[:bans])
      end
      unless @bans.errors && @bans.errors.size.to_bool
        redirecting t(:r_added), '/admin/bans'
        return
      else
        render 'add_edit_ban' and return
      end
    end
      
    if params[:act] == 'drop'
      if Ban.exists?(params[:id])
        Ban.destroy params[:id]
        redirecting t(:r_removed), '/admin/bans'
        return
      end
    end
    @ban_list = Ban.all
  end
  
  def reports
    if params[:reports]
      Report.mark_as_readed(params[:reports], @usr.id)
      redirecting t(:redir), session[:last_page]
      return
    end
    @reports = Report.paginate_by_id Report.get_new_reports, :page => params[:page], :order => 'created_at asc', :per_page => @usr.pagination_posts_amount
  end
  
  def prune_topics
    @options = create_forums_optgroup
    if params[:prune]
      if params[:prune][:confirm]
        if params[:prune][:confirm] == t(:destroy_btn) && Subpartition.exists?(flash[:prune][:subpartition])
          Topic.prune_topics(flash[:prune][:subpartition].to_i, flash[:prune][:days_old].to_i, @usr)
          redirecting t(:r_pruned), '/admin/prune_topics'
          return
        end     
        redirecting t(:r_cans), '/admin/prune_topics'
        return
      end
      flash[:prune] = params[:prune]
      if flash[:prune][:subpartition].to_i == 0
        flash[:prune][:numb_topics] = Topic.find(:all, :conditions => ["last_post < ? or last_post = ?", (Time.now.utc - flash[:prune][:days_old].to_i.days), (Time.now.utc - flash[:prune][:days_old].to_i.days)]).size
      else
        flash[:prune][:numb_topics] = Topic.find(:all, :conditions => ["subpartition_id = ? and (last_post < ? or last_post = ?)", flash[:prune][:subpartition].to_i, (Time.now.utc - flash[:prune][:days_old].to_i.days), (Time.now.utc - flash[:prune][:days_old].to_i.days)]).size
      end
      render 'prune_topic_confirmation' and return
    end
  end
  
  def maintenance
    if params[:maintenance]
      Configs.find_by_name('enable_maintenance').update_attributes(:value => params[:maintenance][:enable])
      Configs.find_by_name('maintenance_text').update_attributes(:value => params[:maintenance][:message])
      redirecting t(:redir), session[:last_page]
      return
    end
  end
  
  def attachments
    flash[:attach] = {:count => 50, :min_size => 0, :max_size => 0, :user => 0, :topic => 0, :orderby => 'id', :order => {:asc => true, :desc => false}}
    attachments = AttachFile.all     
    if params[:attach]
      p = {}
      p[:attach] = params[:attach]
      attachments = AttachFile.filter_by(p)
      flash[:attach] = params[:attach]
      if params[:attach][:order] == 'desc'
        flash[:attach][:order] = {:asc => false, :desc => true}
      else
        flash[:attach][:order] = {:asc => true, :desc => false}
      end
    end
    if params[:attach] && params[:attach][:count]
      per_page = params[:attach][:count]
    else
      per_page = flash[:attach][:count]
    end
    @paginated_attaches = AttachFile.paginate attachments, :page => params[:page], :per_page => per_page
  end
  
  def message
    flash.keep
    render :layout => 'forum'
  end

  private
  def redirect_to_error_page error_message = t(:def_msg)
    flash[:admin_message] = error_message
    redirect_to :action => 'message' and return true
  end
    
  def check_user_privileges
    unless ! @usr.nil? && (@usr.group.admin? || @usr.group.moderator?)
      redirect_to_error_page
    end
  end

  def check_moderator_privileges
    if @usr.group.moderator?
      redirect_to_error_page
    end
  end
   
  def get_setup_page_params
    ['board_title','board_desc','default_style','default_lang',
      'default_timezone','dst','default_timeformat',
      'default_dateformat','visit_timeout','online_timeout',
      'redirect_timeout','topperpage','postsperpage',
      'topreview','rec_meth']
  end
   
  def get_features_page_params
    ["allow_search", "allow_rank", "allow_cens",
      "allow_jumpmenu", "show_version", "show_usersonline",
      "show_quickpost", "allow_topicssubsc", "allow_guestpost",
      "allow_usersdot", "show_views", "allow_postcount",
      "show_userinfo", "allow_bbc", "allow_bbc_img",
      "show_graphsmiles", "allow_bbcurl", "allow_capitals",
      "allow_capitalssubj", "allow_signature", "allow_bbcsignature",
      "allow_bbcimgsignature", "convert_smilestoicon", "allow_capitalssign",
      "allow_avatars", "quote_depth", "maxchar_signature", "maxlines_signature",
      "dir_avatars", "maxwidth_avatars", "maxheight_avatars", "maxsize_avatars"]
  end
          
  def get_email_page_params
    ["admin_email", "webmaster_email", "mailing_list", "smtp_address",
      "smtp_username", "smtp_password", "smtp_ssl"]
  end
                  
  def get_registration_page_params
    ["allow_registration", "verify_registration", "email_registration",
      "email_registration_dub", "email_notify", "use_rules",
      "email_default", "rules_text"]
  end

  def ban_moderation_permission
    if @usr.group.moderator? && ! @usr.group.g_mod_ban_users
      redirect_to_error_page
    end
  end
   
  def save_default_group params
    if params[:act] == 'setdef'
      Configs.find_by_name('default_group').update_attribute(:value, params[:def_groups])
      redirecting t(:redir), '/admin/groups'
      return
    end
  end

  def delete_group params
    if params[:act] == 'drop'
      begin
        Group.find(params[:ident]).forum_perms.each{|perm| ForumPerm.delete(perm.id)}
        Group.find(params[:ident]).delete
        redirecting t(:redir), '/admin/groups'
        return
      rescue => except
        render :text => except.message
        return
      end
    end
  end  
end
