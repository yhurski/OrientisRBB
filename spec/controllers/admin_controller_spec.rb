require 'spec_helper'

describe AdminController do

  before(:all) do
    %x(rake db:seed RAILS_ENV=test) 
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
    @group_permissions = flexmock(:model, Group)
    @usr = flexmock(:model, User, :id => 1, :name => 'pupkin', :email => 'pupkin@gmail.com', :group => @group_permissions, :forum_style => 'default')
    @usr.should_receive(:attr).and_return(true)
  end
  
  before(:each) do
    session[:user_id]  = 1
#    flexmock(controller).should_receive(:get_user).and_return(@usr)
    flexmock(controller).should_receive(:check_user_privileges).and_return(true)
    flexmock(controller).should_receive(:check_moderator_privileges).and_return(true)
    flexmock(controller).should_receive(:ban_moderation_permission).and_return(true)
    flexmock(controller).should_receive(:put_last_page_in_session).and_return(true)
    flexmock(controller).should_receive(:deny_banned_user).and_return(true)
    flexmock(controller).should_receive(:set_locale).and_return(true)
    flexmock(controller).should_receive(:checking_maintenance_mode).and_return(true)
    flexmock(controller).should_receive(:fill_board_skin).and_return(true)    
    flexmock(controller).should_receive(:get_board_cover).and_return(true)    
  end

  describe "get 'info'" do
    it 'should be successful' do
      @usr.should_receive(:attr).and_return(true)
      assigns[:usr] = @usr
      debugger
      get 'info'
      response.should be_success
    end
    
    it 'should render info template' do
      @usr.should_receive(:attr).and_return(true)
      assigns[:usr] = @usr
      get 'info'
      response.should render_template('info')
    end
  end
  
  describe "get 'manage_subpartitions'" do
    it 'should be successful' do
      get 'manage_subpartitions'
      response.should be_success
    end
    
    it 'should render manage_subpartitions template' do
      get 'manage_subpartitions'
      response.should render_template('manage_subpartitions')
    end
    
    it 'should be redirected to manage_subpartitions' do
      subpartition = flexmock(:model, Subpartition)
      subpartition.should_receive(:set_default_perms).and_return(true)
      #flexmock(Subpartition).new_instances.should_receive(:set_default_perms).and_return(true)
      flexmock(Subpartition).should_receive(:create).and_return(subpartition)
      get 'manage_subpartitions', {:add => true}
      response.should redirect_to(:action => 'manage_subpartitions')
    end
    
    it 'should create new subpartition' do
      get 'manage_subpartitions', {:add => true}
      assigns(:new_subpartitions).should_not be_nil
    end
  end
  
  describe "get 'manage_partitions'" do
    it 'should be successful' do
      get 'manage_partitions'
      response.should be_success
    end
    
    it 'should render manage_partitions template' do
      get 'manage_partitions'
      response.should render_template('manage_partitions')
    end
    
    it 'should be redirected to manage_partitions' do
      flexmock(Partition).should_receive(:create).and_return(flexmock(:model, Partition))
      get 'manage_partitions', {:add => true}
      response.should redirect_to(:action => 'manage_partitions')
    end
    
    it 'should create new partition' do
      get 'manage_partitions', {:add => true}
      assigns(:result_part).should_not be_nil
    end
  end
  
  #TODO: find in view
  describe "get 'edit_subpartitions'" do
    it ''
    it ''
  end
  
  describe "get 'drop_subpartition'" do
    it 'should be redirected to message' do
      get 'drop_subpartition'
      response.should redirect_to(:action => 'message')
    end
    
    it 'should be redirected to manage_subpartitions' do
      flexmock(Subpartition).should_receive(:exists?).and_return(true)
      flexmock(Subpartition).should_receive(:destroy).and_return(true)
      get 'drop_subpartition', {:id => 1}
      response.should redirect_to(:action => 'manage_subpartitions')
    end
  end
  
  describe "get 'setup'" do
    it 'should be successful' do
      get 'setup'
      response.should be_success
    end
    
    it 'should render setup template' do
      get 'setup'
      response.should render_template('setup')
    end
    
    it 'should be redirected to setup page' do
      flexmock(controller).should_receive(:get_setup_page_params).and_return(true)
      flexmock(controller).should_receive(:save_config_params).and_return(true)
      @config = flexmock(:model, Configs)
      @config.should_receive(:valid?).and_return(true)
      assigns[:config] = @config
      get 'setup', {:commit => true}, {:last_page => '/admin/info'}
      response.should redirect_to(:action => 'info')
    end
    
    it 'should create config variable' do
      pending
    end
  end
  
  describe "get 'features'" do
    it 'should be successful' do
      get 'features'
      response.should be_success
    end
    
    it 'should render features template' do
      get 'features'
      response.should render_template('features')
    end
    
    it 'should be redirected to features page' do
      flexmock(controller).should_receive(:get_setup_page_params).and_return(true)
      flexmock(controller).should_receive(:save_config_params).and_return(true)
      assigns[:config] = flexmock(:model, Configs).should_receive(:valid?).and_return(true)
      get 'features', {:commit => true}, {:last_page => '/admin/info'}
      response.should redirect_to(:action => 'info')
    end
  end
  
  describe "get 'notices'" do
    it 'should be successful' do
      get 'notices'
      response.should be_success
    end
    
    it 'should render notices template' do
      get 'notices'
      response.should render_template('notices')
    end
    
    it 'should be redirected to notices' do
      flexmock(Configs).should_receive(:update_notices).and_return(true)
      get 'notices', {:notices => {:allow_notices => true, :notice_title => '123', :notice_message => '123'}}, {:last_page => '/admin/notices'}
      response.should redirect_to(:action => 'notices')
    end
  end
  
  describe "get 'email'" do
    it 'should be successful' do
      get 'email'
      response.should be_success
    end
    
    it 'should render email template' do
      get 'email'
      response.should render_template('email')
    end
    
    it 'should be redirected to email' do
      flexmock(controller).should_receive(:get_email_page_params)
      flexmock(controller).should_receive(:save_config_params)
      get 'email', {:commit => true}, {:last_page => '/admin/email'}
    end
  end
  
  describe "get 'registration'" do
    before(:each) do
      flexmock(controller).should_receive(:get_registration_page_params).and_return(true)
    end
    
    it 'should be successful' do
      get 'registration'
      response.should be_success
    end
    
    it 'should render registration template' do
      get 'registration'
      response.should render_template('registration')
    end    
    
    it 'should be redirected to registration' do
      flexmock(controller).should_receive(:save_config_params).and_return(true)
      get 'registration', {:commit => true}, {:last_page => '/admin/registration'}
      response.should redirect_to(:action => 'registration')
    end
  end
  
  describe "get 'censoring'" do
    it 'should be successful' do
      get 'censoring'
      response.should be_success
    end
    
    it 'should render censoring template' do
      get 'censoring'
      response.should render_template('censoring')
    end
    
    it 'should set variables' do
      get 'censoring'
      assigns(:censor).should_not be_nil
      assigns(:censorsAll).should_not be_nil
    end
    
    it 'should be redirected to censoring page' do
      flexmock(Censor).should_receive(:exists?).and_return(true)
      flexmock(Censor).should_receive(:update).and_return(true)
      get 'censoring', {:censors => true, :submit => 'Update'}, {:last_page => '/admin/censoring'}
      response.should redirect_to(:action => 'censoring')
    end
  end
  
  describe "get 'attach'" do
    it 'should be successful' do
      get 'attach'
      response.should be_success
    end
    
    it 'should render attach template' do
      get 'attach'
      response.should render_template('attach')
    end
  
    it 'should be redirected to attach page' do
      flexmock(Configs).should_receive(:save_attach_configuration).and_return(true)
      get 'attach', {:act => 'save'}, {:last_page => '/admin/attach'}
      response.should redirect_to(:action => 'attach')
    end
  end
  
  describe "get 'search'" do
    it 'should be successful' do
      get 'search'
      response.should be_success
    end
    
    it 'should render search template' do
      get 'search'
      response.should render_template('search')
    end
    
    it 'should render search_results template' do
      flexmock(User).should_receive(:perform_full_search).and_return([flexmock(:model, User), flexmock(:model, User)])
      get 'search', {:act => 'search'}
      response.should render_template('search_results')
    end
    
    it 'should set searched_usrs variable' do
      flexmock(User).should_receive(:perform_full_search).and_return([flexmock(:model, User), flexmock(:model, User)])
       get 'search', {:act => 'search'}
       assigns(:searched_usrs).should_not be_empty
    end
  end
  
  describe "get 'user_ip'" do
    it 'should be successful' do
      get 'user_ip'
      response.should be_success
    end
    
    it 'should render user_ip template' do
      get 'user_ip'
      response.should render_template('user_ip')
    end
    
    it 'should set user_ip_posts variable' do
      flexmock(User).should_receive(:exists?).and_return(true)
      flexmock(User).should_receive(:find).and_return(@usr)
      flexmock(Post).should_receive(:find).and_return([flexmock(:model, Post), flexmock(:model, Post)])
     # debugger
      get 'user_ip', {:id => 1}
      assigns(:user_ip_posts).should_not be_empty
    end
    
    it 'should set searched_usrs variable' do
      flexmock(User).should_receive(:exists?).and_return(true)
      flexmock(User).should_receive(:find_by_sql).and_return([flexmock(:model, User), flexmock(:model, User)])
      get 'user_ip', {:id => 1}
      assigns(:searched_usrs).should_not be_empty
    end
    
    it 'should render search_results template' do
      flexmock(User).should_receive(:exists?).and_return(true)
      flexmock(User).should_receive(:find).and_return(@usr)
      flexmock(User).should_receive(:find_by_sql).and_return([flexmock(:model, User), flexmock(:model, User)])
      get 'user_ip', {:id => 1}
      response.should render_template('search_results')
    end
  end
  
  describe "get 'show_host'" do
    it 'should be successful' do
      get 'show_host'
      response.should be_success
    end
    
    it 'should render show_host template' do
      get 'user_ip'
      response.should render_template('show_host')
    end
    
    it 'should set hostname variable' do
      get 'user_ip', {:ip => '127.0.0.1'}
      assigns(:hostname).should_not be_nil
    end
  end
  
  describe "get 'user_posts'" do
    it 'should be redirected to message' do
      get 'user_posts'
      response.should redirect_to(:action => 'message')
    end
    
    it 'should be successful' do
      flexmock(User).should_receive(:exists?).and_return(true)
      get 'user_posts', {:id => 1}
      response.should be_success
    end
    
    it 'should render user_posts template' do
      flexmock(User).should_receive(:exists?).and_return(true)
      get 'user_posts', {:id => 1}
      response.should render_template('user_posts')
    end
  end
  
  describe "get 'groups'" do
    it 'should be successful' do
      get 'groups'
      response.should be_success
    end
    
    it 'should render groups template' do
      get 'groups'
      response.should render_template('groups')
    end
    
    it 'should be redirected to groups and set default' do
      get 'groups', {:act => 'setdef', :def_groups => 1}
      response.should redirect_to(:action => 'groups')
    end
    
    it 'should be redirected to groups and drop' do
      get 'groups', {:act => 'drop', :ident => 1}
      response.should redirect_to(:action => 'groups')
    end
  end

  describe "get 'addgroup'" do
    it 'should be redirected to message' do
      get 'addgroup'
      response.should redirect_to(:action => 'message')
    end

    it 'should be redirected to groups' do
      flexmock(Group).should_receive(:create).and_return(true)
      get 'addgroup', {:group => true}
      response.should redirect_to(:action => 'groups')
    end

    it 'should render add_group template' do
      flexmock(Group).should_receive(:exists?).and_return(true)
      group = flexmock(:model, Group).should_receive(:forum_perms).and_return(flexmock(:model, ForumPerm))
      flexmock(Group).should_receive(:find).and_return(group)
#      debugger
      get 'addgroup', {:parent_group => 1}
      response.should render_template('add_group')
    end
  end

  describe "get 'editgroup'" do
    it 'should be redirected to message' do
      get 'editgroup'
      response.should redirect_to(:action => 'message')
    end

    it 'should render add_group template' do
      flexmock(Group).should_receive(:exists?).and_return(true)
      group = flexmock(:model, Group)
      group.should_ignore_missing
      flexmock(Group).should_receive(:find).and_return(group)
      get 'editgroup', {:ident => 1}
      response.should render_template('add_group')
    end

    it 'should be redirected to groups' do
      flexmock(Group).should_receive(:exists?).and_return(true)
      group = flexmock(:model, Group)
      group.should_receive(:errors).and_return([])
      group.should_ignore_missing
      flexmock(Group).should_receive(:find).and_return(group)
      flexmock(Group).should_receive(:create).and_return(true)
      get 'editgroup', {:ident => 1, :group => {:id => nil}}
      response.should redirect_to(:action => 'groups')
    end
  end

  describe "get 'ranks'" do
    it 'should be successful' do
      get 'ranks'
      response.should be_success
    end

    it 'should render ranks template' do
      get 'ranks'
      response.should render_template('ranks')
    end

    it 'should be redirected to ranks' do
      get 'ranks', {:ranks => {}}, {:last_page => '/admin/ranks'}
      response.should redirect_to(:action => 'ranks')
    end
  end
  
  describe "get 'bans'" do
    it 'should be successful' do
      get 'bans'
      response.should be_success
    end

    it 'should render bans template' do
      get 'bans'
      response.should render_template('bans')
    end

    it 'should render add_edit_ban template with existing record' do
      bans = flexmock(:model, Ban)
      flexmock(Ban).should_receive(:exists?).and_return(true)
      flexmock(Ban).should_receive(:find).and_return(bans)
      get 'bans', {:act => 'edit'}
      response.should render_template('add_edit_ban')
    end

    it 'should be redirected to bans and create new' do
      bans = flexmock(:model, Ban)
      bans.should_receive(:errors).and_return([])
#      flexmock(Ban).should_receive(:exists?).and_return(true)
      flexmock(Ban).should_receive(:find_by_username).and_return(bans)
      flexmock(@usr).should_receive(:user_date_to_utc).and_return(Time.now.utc +  10.days)
     # assigns[:usr] = @usr
#     debugger
      @usr.should_receive(:id).and_return(2)
      assigns[:usr] = @usr
      debugger
      get 'bans', {:act => 'save', :bans => {}}
#      debugger
      response.should redirect_to(:action => 'bans')
    end

    it 'should be redirected to bans and drop existing' do
      flexmock(Ban).should_receive(:exists?).and_return(true)
      flexmock(Ban).should_receive(:destroy).and_return(true)
      get 'bans', {:act => 'drop'}
      response.should redirect_to(:action => 'bans')
    end
  end

  describe "get 'reporst'" do
    it 'should be successful' do
      get 'reports'
      response.should be_success
    end

    it 'should render reports template' do
      get 'reports'
      response.should render_template('reports')
    end

    it 'should be redirected to reports' do
      flexmock(Report).should_receive(:mark_as_readed).and_return(true)
      get 'reports', {:reports => {}}, {:last_page => '/admin/reports'}
      response.should redirect_to(:action => 'reports')
    end
  end
  
  describe "get 'prune_topics'" do
    before(:each) do
      flexmock(controller).should_receive(:create_forums_optgroup).and_return(flexmock(:model, Subpartition))
    end
    
    it 'should be successful' do
      get 'prune_topics'
      response.should be_success
    end
    
    it 'should render prune_topics template' do
      get 'prune_topics'
      response.should render_template('prune_topics')
    end
    
    it 'should set options variable' do
      get 'prune_topics'
      assigns(:options).should_not be_nil
    end
    
    it 'should render prune_topic_confirmation templage' do
      get 'prune_topics', {:prune => {}}
      response.should render_template('prune_topic_confirmation')
    end
    
    it 'should be redirected to prune_topics' do
      flexmock(Subpartition).should_receive(:exists?).and_return(true)
      flexmock(Topic).should_receive(:prune_topics).and_return(true)
      flash[:prune] = {:subpartition => 1}
      get 'prune_topics', {:prune => {:confirm => 'Yes'}}
      response.should redirect_to(:action => 'prune_topics')
    end
  end
  
  describe "get 'maintenance'" do
    it 'should be successful' do
      get 'maintenance'
      response.should be_success
    end
    
    it 'should render maintenance template' do
      get 'maintenance'
      response.should render_template('maintenance')
    end
    
    it 'should be redirected to maintenance' do
      flexmock(Configs).should_receive(:find_by_name).and_return(flexmock(:model, Configs).should_receive(:update_attributes).and_return(true))
      get 'maintenance', {:maintenance => {:enable => true, :message => '123'}}
      response.should redirect_to(:action => 'maintenance')
    end
  end
  
  describe "get 'attachments'" do
    before(:each) do
      flexmock(AttachFile).should_receive(:paginate).and_return([flexmock(:model, AttachFile), flexmock(:model, AttachFile)])
    end
    
    it 'should be successful' do
      get 'attachments'
      response.should be_success
    end
    
    it 'should render attachments template' do
      get 'attachments'
      response.should render_template('attachments')
    end
    
    it 'should set paginated_attaches variable' do
      get 'attachments'
      assigns(:paginated_attaches).should_not be_nil
    end
  end
end
