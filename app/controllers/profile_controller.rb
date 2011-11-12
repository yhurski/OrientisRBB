class ProfileController < ApplicationController
  skip_before_filter :get_group_permissions
  
  before_filter :get_user
  before_filter :user_should_be, :except => ['message']
  around_filter :check_user_privileges
  before_filter :alien_profile_administration_permission, :only => ['administration']
  before_filter :manage_avatar, :only => ['avatar', 'rem_avatar']
  after_filter :put_last_page_in_session, :except => ['rem_avatar', 'message']
  before_filter :forbid_for_moderator, :only => ['change_pass', 'change_email']
  before_filter :change_alien_password_permission, :only => ['change_alien_password']
  before_filter :get_group_permissions
  
  def main
    @board_langs = get_board_langs
    if params[:users]
      unless @board_langs.include? params[:users][:forum_lang]
        @usr.errors.add('forum_lang', t(:undef_lang)) and return
      end
      unless ActiveSupport::TimeZone.all.map(&:name).include? params[:users][:timezone]
        @usr.errors.add('timezone', t(:undef_tz)) and return
      end
      @usr.isvalidate = false
      @usr.update_attributes(:timezone => params[:users][:timezone], :forum_lang => params[:users][:forum_lang], :dst => params[:users][:dst])
      @usr.isvalidate = true
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
  end
 
  def personal
    if params[:users]
      @usr.isvalidate = false
      if (@privilege_user && @privilege_user.admin?) || (@privilege_user.group.moderator? && ! @usr.group.moderator? && ! @usr.admin?)
        @usr.update_attributes(:realname => params[:users][:realname], :location => params[:users][:location], :web => params[:users][:web], :title => params[:users][:title],
          :numposts => params[:users][:numposts], :adminnote => params[:users][:adminnote], :email => params[:users][:email])
        @usr.update_attributes(:name, params[:users][:name]) if @privilege_user.group.g_mod_rename_users
      else
        @usr.update_attributes(:realname => params[:users][:realname], :location => params[:users][:location], :web => params[:users][:web], :title => params[:users][:title])
      end
      @usr.isvalidate = true
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
  end

  def communication
    if params[:users]
      @usr.isvalidate = false
      @usr.update_attributes(:jabber => params[:users][:jabber], :icq => params[:users][:icq], :msn => params[:users][:msn], :aim => params[:users][:aim], :yahoo => params[:users][:yahoo])
      @usr.isvalidate = true
      if @usr.valid?
        redirecting t(:redir), session[:last_page]
        return
      end          
    end
  end

  def individual
    if params[:users]
      @usr.isvalidate = false
      @usr.update_attributes(:signature => params[:users][:signature])
      @usr.isvalidate = true
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
  end

  def view
    if params[:users]
      @usr.isvalidate = false
      @usr.update_attributes(:forum_style => params[:users][:forum_style], :smiles_to_img => params[:users][:smiles_to_img], :show_users_sign => params[:users][:show_users_sign],
        :show_img_inmess => params[:users][:show_img_inmess], :show_img_insign => params[:users][:show_img_insign], :themes_per_page => params[:users][:themes_per_page],
        :posts_per_page => params[:users][:posts_per_page])
      @usr.isvalidate = true
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
    @styles = get_board_styles
    fill_board_skin
  end

  def private
    if params[:users]
      @usr.update_attribute(:howshowemail, params[:users][:howshowemail])
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
  end

  def avatar
    if params[:user]
      unless Configs.is_allowed_img(params[:user][:avatar].original_path)
        @ext_error = t(:file_error)
        return
      end
      @usr.save_avatar(params[:user])
      if @usr.errors.empty?
        redirecting(t(:redir), session[:last_page])
        return
      end
    end
  end
  
  def messages
    posts_topics = []
    @usr.posts.sort{|first, second| second.posted <=> first.posted}.each{|post| posts_topics << post.topic}
    posts_topics = posts_topics.uniq.sort{|first, second| second.get_last_user_post(@usr).posted <=> first.get_last_user_post(@usr).posted}
    @topics = Topic.paginate posts_topics, :page => params[:page], :per_page => @usr.themes_per_page
  end

  def rem_avatar
    @usr.avatar.destroy
    @usr.clear_avatar
    redirecting t(:redir), "/profile/avatar/#{params[:id]}"
  end

  def change_pass
    if params[:users]
      unless @usr.proper_password?(params[:users][:old_passwd])
        @usr.errors.add('old_passwd', t(:old_password_error))
        render :layout => 'addendum' and return 
      end
      @usr.update_attributes(:passwd => params[:users][:passwd],#User.get_md5_passwd_hash(params[:users][:passwd], @usr.salt),
        :passwd_confirmation => params[:users][:passwd_confirmation],#User.get_md5_passwd_hash(params[:users][:passwd_confirmation], @usr.salt),
        :new_email => @usr.email)
      if @usr.errors.empty?
        redirecting t(:redir), '/profile/main'
        return
      end
    end
    render :layout => 'addendum'
  end

  def change_email
    if params[:users]
      unless @usr.proper_password?(params[:users][:passwd])
        @usr.errors.add('passwd', t(:email_error))
        render :layout => 'addendum' and return
      end
      @usr.update_attributes(:email => params[:users][:new_email], :new_email => params[:users][:new_email])
      if @usr.errors.empty?
        redirecting t(:redir), '/profile/main'
        return
      end
    end
    render :layout => 'addendum'
  end

  def administration
    if params[:profile]
      @usr.update_attribute(:group_id, params[:profile][:group])
      @usr.subpartitions.clear
      if Group.find(params[:profile][:group]) && Group.find(params[:profile][:group]).g_moderator
        @usr.subpartitions << Subpartition.find(params[:profile][:moderator].keys) if params[:profile][:moderator]
      end
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
        return
      end
    end
    @partitions = Partition.all
    @groups = Group.all.select{|group| group.id != Group.get_guest.id}
  end

  def change_alien_password
    if params[:users]
      @usr.update_attributes(:passwd => params[:users][:passwd], :passwd_confirmation =>params[:users][:passwd_confirmation], :new_email => @usr.email)
      if @usr.errors.empty?
        redirecting t(:redir), session[:last_page]
      end
    end
  end

  def message
    flash.keep
  end

  private
  def redirect_to_info_page message=t(:def_msg)
    flash[:permission_message] = message
    redirect_to :action => 'message'
  end

  def alien_profile_administration_permission 
    unless @privilege_user.admin? || (@privilege_user.group.g_mod_ban_users && @privilege_user.group.moderator? && ! @usr.group.moderator? && ! @usr.admin?)
      redirect_to_info_page
    end
  end
  
  def manage_avatar
    unless Configs.get_config('allow_avatars').to_bool
      redirect_to_info_page
    end
  end

  def forbid_for_moderator
    if @privilege_user != @usr
      redirect_to_info_page t(:unknown_act)
    end
  end

  def change_alien_password_permission
    unless @privilege_user.admin? || (@privilege_user.group.g_mod_change_password && @privilege_user.group.moderator? && ! @usr.group.moderator? && ! @usr.admin?)
      redirect_to_info_page
    end
  end
  
  def user_should_be
    unless @usr
      flash[:permission_message] = t(:def_msg)
      redirect_to :controller => 'forum', :action => 'message' and return
    end
  end
end