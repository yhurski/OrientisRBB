require 'spec_helper'

describe ForumController do
  #integrate_views
  before(:all) do
    %x(rake db:seed RAILS_ENV=test) 
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
    @group_permissions = flexmock('Group')
    @group_permissions.should_receive(:id).and_return(1)
    @usr = flexmock('User')    
    @usr.should_receive(:id).and_return(1)
    @usr.should_receive(:name).and_return('pupkin')
    @usr.should_receive(:email).and_return('pupkin@gmail.com')
    #@usr.should_receive(:get_guest).and_return(@
    flexmock(User).should_receive(:get_guest).and_return(@usr)
    @usr.should_receive(:group).and_return(@group_permissions)
   # flexmock(Configs).should_receive(:get_config).with('redirect_timeout').and_return(0)
  end
  

  #Delete these examples and add some real ones
  it "should use ForumController" do
    controller.should be_an_instance_of(ForumController)
  end

  describe "GET 'main'" do
    before(:all) do
     # @controller = ForumController.new
     # flexmock(controller).should_receive(:get_user).and_return(@usr)
     # flexmock(controller).should_receive(:get_group_permissions).and_return(@group_permissions)
     # flexmock(controller).should_receive(:check_online3).and_return(true)
     # flexmock(controller).should_receive(:remove_online2).and_return(true)
     # flexmock(controller).should_receive(:read_forum_permission).and_return(true)
   #   flexmock(controller).should_ignore_missing
    end
    
    it "should be successful" do
      flexmock(User).should_receive(:get_guest).and_return(@usr)
      flexmock(controller).should_receive(:remove_online2).and_return(true)
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      get 'main'
      response.should be_success
    end
    
    it 'should render main template' do
      flexmock(User).should_receive(:get_guest).and_return(@usr)
      flexmock(controller).should_receive(:remove_online2).and_return(true)
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      #debugger
      get 'main'
      response.should render_template('main')
    end
    
    it 'should return at least one partition' do
      get 'main'
      assigns(:partitions).should_not be_empty
    end
  end
  
   describe "get 'view_topics'" do
    before(:all) do
      @usr.should_receive(:pagination_topics_amount).and_return(30)
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:get_drop_down_menu_data).and_return(true)
      flexmock(Subpartition).should_receive(:exists?).and_return(true)
      flexmock(Topic).should_receive(:paginate).and_return([flexmock(Topic), flexmock(Topic)])
    end
     
    it 'should be sucessful' do
      get 'view_topics', {:id => 1}
      response.should be_success
    end
    
    it 'should render view_topics template' do
      get 'view_topics', {:id => 1}
      response.should render_template('view_topics')
    end
    
    it 'should be redirected' do
      get 'view_topics', {:id => 0}
      response.should redirect_to(:action => 'message')
    end
    
    it 'should return at least one topic' do
      get 'view_topics', {:id => 1}
      assigns(:topics).should_not be_empty
    end
     
   end
   
  describe "get 'view_posts'" do
     before(:all) do
      @usr.should_receive(:pagination_posts_amount).and_return(20)
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
    #  flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:get_drop_down_menu_data).and_return(true)
      flexmock(Topic).should_receive(:exists?).and_return(true)
      flexmock(Topic).should_receive(:find).and_return([flexmock(Topic), flexmock(Topic)])
      flexmock(Post).should_receive(:paginate).and_return([flexmock(Post), flexmock(Post)])
    end
    
    it 'should be successful' do
      flexmock(controller).should_receive(:get_drop_down_menu_data).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:put_post_time).and_return(true)
      get 'view_posts', {:id => 1}
      response.should be_success
    end

    it 'should be redirected' do
      get 'view_posts', {:id => 0}
      response.should redirect_to(:action => 'message')
    end

    it 'should return at least one post' do
      get 'view_posts', {:id => 1}
      assigns(:post).should_not be_empty
    end
  end
  
  describe "get 'new_topic'" do
    before(:all) do
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:clear_postreply_session).and_return(true)
      flexmock(controller).should_receive(:post_topic_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:post_flood_timeout_check).and_return(true)
      flexmock(controller).should_receive(:new_post_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:post_topic_subpartition_permission).and_return(true)
    end
    
    before(:each) do
      flexmock(controller).should_receive(:post_topic_subpartition_permission).and_return(true)
    end
    
    it 'should be successful' do
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:clear_postreply_session).and_return(true)
      flexmock(controller).should_receive(:post_topic_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:post_flood_timeout_check).and_return(true)
      flexmock(controller).should_receive(:new_post_subpartition_permission).and_return(true)
      get 'new_topic', {:id => 1}
      response.should be_success
    end
    
    it 'should return new_topic template' do
      flexmock(controller).should_receive(:post_topic_subpartition_permission).and_return(true)
      get 'new_topic', {:id => 1}
      #debugger
      response.should render_template('new_topic')
    end
    
    it 'should be redirected' do
      @new_post = flexmock(Post)
      @new_post.should_receive(:nil?).and_return(false)
      flexmock(controller).should_receive(:topic_receiver).and_return(@new_post)
      get 'new_topic', {:id => 1, :post => 1}, {:last_page => '/forum/main'}
      #debugger
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'edit_topic'" do
    before(:all) do

    end
    
    it 'should be successful' do
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:clear_postreply_session).and_return(true)
      get 'edit_topic', {:id => 1, :post => 1}
      response.should be_success
    end
    
    it 'should return edit_topic template' do
      get 'edit_topic', {:id => 1, :post => 1}
      response.should render_template('edit_topic')
    end
    
    it 'should be redirected' do
      @new_post = flexmock(Post)
      flexmock(controller).should_receive(:topic_receiver).and_return(@new_post)
      @topic = flexmock(Topic)
      @topic.should_receive(:id).and_return(1)
      get 'edit_topic', {:id => 1, :post => 1}
      response.should redirect_to(:action => 'view_posts', :id => @topic.id)
    end
  end
  
  describe "get 'delete_topic'" do
    before(:all) do
      flexmock(controller).should_receive(:read_forum_permission).and_return(true)
      flexmock(controller).should_receive(:read_subpartition_permission).and_return(true)
      flexmock(controller).should_receive(:clear_postreply_session).and_return(true)
      flexmock(controller).should_receive(:delete_topics_permission).and_return(true)
      flexmock(controller).should_receive(:clear_postreply_session).and_return(true)
    end
    
    before(:each) do
      #debugger
      flexmock(controller).should_receive(:delete_topics_permission).and_return(true)
    end
    
    it 'should be successful' do
      flexmock(Topic).should_receive(:exists?).and_return(true)
      flexmock(Topic).should_receive(:find).and_return(true)
      get 'delete_topic', {:id => 1}
      response.should be_success
    end
    
    it 'should render delete_topic template' do
      get 'delete_topic', {:id => 1}
      response.should render_template('delete_topic')
    end
    
    it 'should delete and be redirected' do
      get 'delete_topic', {:id => 1, :delete => true}
    #  debugger
      assigns(:topic).should_not be_nil
      response.should redirect_to(:action => 'view_topics', :id => assigns(:topic).subpartition.id)
    end
    
    it 'should be redirected' do
      get 'delete_topic', {:id => 1, :cancel => true}, {:last_page => '/forum/main'}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'delete_post'" do
    it 'should be successful' do
      get 'delete_post'
      response.should be_success
    end
    
    it 'should be redirected to message' do
      get 'delete_post'
      response.should redirect_to(:action => 'message')
    end
    
    it 'should delete and be redirected' do
      get 'delete_post', {:id => 1, :commit => 'Remove', :remove_acceptance => true}, {:last_page => '/forum/main'}
      assigns(:dropped_post).should_not be_nil
      response.should redirect_to(:action => 'main')
    end
    
    it 'should be redirected' do
      get 'delete_post', {:id => 1, :commit => true}, {:last_page => '/forum/main'}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'login'" do
    it 'should be successful' do
      get 'login'
      response.should be_success
    end
    
    it 'should render login template' do
      get 'login'
      response.should render_template('login')
    end
    
    it 'should login and be redirected to main' do
      flexmock(Online).should_receive(:find_by_ip).and_return(nil)
      get 'login', {:user => {:username => 'admin', :password => 'admin'}}
      session[:user_id].should_not be_nil
      response.should redirect_to(:action => 'main')
    end
    
    it 'should login and be redirected to user profile page' do
      online_usr = flexmock('Online')
      online_usr.should_receive(:prev_url).and_return('/profile/main')
      flexmock(Online).should_receive(:find_by_ip).and_return(online_usr)
      get 'login', {:user => {:username => 'admin', :password => 'admin'}}
      session[:user_id].should_not be_nil
      response.should redirect_to(:controller => 'profile', :action => 'main')
    end
  end
  
  describe "get 'logout'" do
    it 'should be successful' do
      get 'logout', nil, {:user_id => 1}
      response.should be_success
    end
    
    it 'should be redirected to main page' do
      get 'logout', nil, {:user_id => 1}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'go_to_forum_page'" do
    it 'should be redirected to main page' do
      get 'go_to_forum_page'
      response.should redirect_to(:action => 'main')
    end
    
    it 'should be redirected to view_topics page' do
      get 'go_to_forum_page', {:forum => {:id => 1}}
      response.should redirect_to(:action => 'view_topics', :id => params[:forum][:id])
    end
  end
  
  describe "get 'regist'" do
    it 'should be successful' do
      get 'regist'
      response.should be_success
    end
    
    it 'should render regist template' do
      get 'regist'
      response.should render_template('regist')
    end
    
    it 'should render message template' do
      flexmock(User).should_receive(:new).and_return(@usr)
      flexmock(User).should_receive(:create_registration_data).and_return(@usr)
      Configs.find_by_name('verify_registration').update_attribute(:value, '1')
      get 'regist', {:users => true}
      response.should redirect_to(:action => 'message')
    end
    
    it 'should be redirected to main page' do
      Configs.find_by_name('verify_registration').update_attribute(:value, '0')
      get 'regist', {:users => true}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'rules_confirmation'" do
    it 'should be successful' do
      get 'regist'
      response.should be_success
    end
    
    it 'should render rules_confirmation template' do
      get 'rules_confirmation'
      response.should render_template('rules_confirmation')
    end
    
    it 'should be redirected to main page' do
      get 'rules_confirmation', {:cancel => true}
      response.should redirect_to(:action => 'main')
    end
    
    it 'should be redirected to regist page' do
      get 'rules_confirmation', {:agree => true, :agree_rules => true}
      response.should redirect_to(:action => 'regist')
    end    
  end
  
  describe "get 'remind'" do
    it 'should be successful' do
      get 'remind'
      response.should be_success
    end
    
    it 'should render remind template' do
      get 'remind'
      response.should render_template('remind')
    end
    
    it 'should be redirected to message' do
      get 'remind', {:user => {:name => 'admin', :email => 'admin@mail.com'}}
      response.should redirect_to(:action => 'message')
    end
    
    it 'should render remind template and return error' do
      get 'remind', {:user => {:name => 'naem', :email => 'naem@mail.com'}}
      assigns(:remind_pass_error).should_not be_blank
      response.should render_template('remind')
    end 
  end
  
  describe "get 'profile'" do
    it 'should be successful' do
      get 'profile', {:id => 1}
      response.should be_success
    end
    
    it 'should render profile template' do
      get 'profile', {:id => 1}
      response.should render_template('profile')
    end
  
    it 'should be redirected to message' do
      get 'profile'
      response.should redirect_to(:action => 'message')
    end
  end
  
  describe "get 'send_email'" do
    it 'should be successful' do
      flexmock(controller).should_receive(:profile_mail_sending).and_return({})
      get 'send_email', {:id => 1, :commit => 'commit'}, {:last_page => '/forum/main'}
      assigns(:sending_res).should_not be_nil
      response.should redirect_to(:action => 'main')
    end
    
    it 'should be redirected to message' do
      flexmock(controller).should_receive(:profile_mail_sending).and_return(nil)
      get 'send_email', {:id => 1, :commit => 'commit'}
      response.should redirect_to(:action => 'message')
    end
  end
  
  describe "get 'show_profile_posts'" do
    it 'should be successful' do
      get 'show_profile_posts', {:id => 1}
      response.should be_success
    end
    
    it 'should render show_profile_posts template' do
      get 'show_profile_posts', {:id => 1}
      response.should render_template('show_profile_posts')
    end
    
    it 'should define @user_profile_posts' do
      get 'show_profile_posts', {:id => 1}
      assigns(:user_profile_posts).should be_defined
    end
    
    it 'should be redirected to message' do
      get 'profile'
      response.should redirect_to(:action => 'message')
    end
  end
  
  describe "get 'report'" do
    it 'should be successful' do
      flexmock(Post).should_receive(:exists?).and_return(true)
      get 'report', {:id => 1}, {:last_page => '/forum/main'}
      response.should be_success
    end
    
    it 'should render report template' do
      get 'report', {:id => 1}
      response.should render_template('report')
    end
    
    it 'should be redirected' do
      get 'report'
      response.should redirect_to(:action => 'message')
    end
    
    it 'should create new and be redirected' do
      flexmock(ReportMailer).should_receive(:deliver_email).and_return(true)
      flexmock(Report).should_receive(:create_new).and_return(true)
      get 'report', {:reports => true, :id => 1}, {:last_page => '/forum/main'}
      response.should to_redirect(:action => 'main')
    end
  end
  
  describe "get 'postreply'" do
    it 'should be redirected to message' do
      get 'postreply'
      response.should redirect_to(:action => 'message')
    end
    
    it 'should be redirected to main page' do
      flexmock(Topic).should_receive(:exists?).and_return(true)
      flexmock(controller).should_receive(:post_receiver).and_return(true)
      @new_post = flexmock(:model, Post)
      get 'postreply', {:id => 1}, {:last_page => '/forum/main'}
    end
  end

  describe "get 'drop_attach'" do
    before(:all) do
      @a = 10
    end

    it 'should be redirected to message' do
      get 'drop_attach'
      response.should redirect_to(:action => 'message')
    end

    it 'should be redirected to postreply action' do
      @post_incomplete = flexmock(:model, Post)
      @post_incomplete.should_receive(:user).and_return(@user)
      @post_incomplete.should_receive(:topic).and_return(flexmock(:model, Topic))
      flexmock(Post).should_receive(:find).and_return(@post_incomplete)
      flexmock(Post).should_receive(:exists?).and_return(true)
      assigns[:post_incomplete] = @post_incomplete
      assigns[:usr] = @user
      get 'drop_attach'
      response.should redirect_to(:action => 'postreply')
    end

    it 'should return error in flash' do
      @post_incomplete = flexmock(:model, Post)
      @post_incomplete.should_receive(:user).and_return(@user)
      assigns(:post_incomplete, @post_incomplete)
      assigns(:usr, @user)
      get 'drop_attach'
      flash.should has(:drop_attach_error)
      flash[:drop_attach_error].should_not be_empty
    end

    it 'should return true in session' do
      @post_incomplete = flexmock(:model, Post)
      @post_incomplete.should_receive(:user).and_return(@user)
      assigns(:post_incomplete, @post_incomplete)
      assigns(:usr, @user)
      get 'drop_attach'
      session.should has(:post_preview_delete_attach)
      session[:post_preview_delete_attach].should be_true
    end
  end

  describe "get 'send_attach'" do
    it 'should be redirected to message' do
      get 'send_attach'
      response.should redirect_to(:action => 'message')
    end

    it 'should be redirected' do
      flexmock(AttachFile).should_receive(:exists?).and_return(:true)
      flexmock(AttachFile).should_receive(:find).and_return(flexmock(:model, AttachFile))
      get 'send_attach', {:id => 1}
      debugger
      response.should be_redirect
    end
  end

  describe "get 'remove_attach'" do
    before(:each) do
      flexmock(controller).should_receive(:allow_attach_permission).and_return(true)
      flexmock(controller).should_receive(:delete_attach_permission).and_return(true)
    end

    it 'shoud be redirected to message' do
      get 'remove_attach'
      response.should redirect_to(:action => 'message')
    end

    it 'should be redirected to main page' do
      flexmock(AttachFile).should_receive(:exists?).and_return(true)
      flexmock(AttachFile).should_receive(:find).and_return(flexmock(:model, AttachFile))
      get 'remove_attach', {:commit => true, :attach_id => 1}, {:last_page => '/forum/main'}
     # debugger
      response.should redirect_to(:action => 'main')
    end
  end

  describe "get 'users_list'" do
    before(:each) do
      flexmock(controller).should_receive(:view_users_permission).and_return(true)
      flexmock(controller).should_receive(:search_users_permission).and_return(true)
      flexmock(User).should_receive(:order_by_asc).and_return(User)
      flexmock(User).should_receive(:find).and_return([flexmock(:model, User), flexmock(:model, User)])
      flexmock(Group).should_receive(:get_guest).and_return(@usr)
    end
    
    it 'should be successful' do
      get 'users_list'
      response.should be_success
    end

    it 'should render users_list template' do
      debugger
      get 'users_list'
      response.should render_template('users_list')
    end

    it 'should return users_list' do
      get 'users_list'
      debugger
      assigns(:users_list).should have(2).users
    end

    it 'should return users_list with parameters' do
      flexmock(User).should_receive(:get_user_list).and_return([flexmock(:model, User)])
      get 'users_list', {:users => true}
      assigns(:users_list).should have(1).users
    end    
  end

  describe "get 'show_new_messages'" do
    it 'should be redirected to message' do
      assigns[:topics] = nil
      get 'show_new_messages'
      response.should redirect_to(:action => 'message')
    end

    it 'should be successful' do
      flexmock(Topic).should_receive(:paginate).and_return([flexmock(:model, Topic), flexmock(:model, Topic)])
      get 'show_new_messages'
      response.should be_success
    end

    it 'should render show_new_messages template' do
      flexmock(Topic).should_receive(:paginate).and_return([flexmock(:model, Topic), flexmock(:model, Topic)])
      get 'show_new_messages'
      response.should render_template('show_new_messages')
    end

  end


  
end
