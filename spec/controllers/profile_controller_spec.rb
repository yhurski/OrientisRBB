require 'spec_helper'

describe ProfileController do
  before(:all) do
    %x(rake db:seed RAILS_ENV=test) 
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
    @group_permissions = flexmock(:model, Group)
    @usr = flexmock(:model, User, :id => 1, :name => 'pupkin', :email => 'pupkin@gmail.com', :group => @group_permissions, :forum_style => 'default',
                                              :proper_password? => true, :change_pass => true, :update_attribute => true)
    @privilege_user = @usr
  end
  
  before(:each) do
    flexmock(controller).should_receive(:get_user).and_return(@usr)
    flexmock(controller).should_receive(:user_should_be).and_return(true)
   # flexmock(controller).should_receive(:check_user_privileges).and_return(true)
    flexmock(controller).should_receive(:get_group_permissions).and_return(true)
    flexmock(controller).should_receive(:put_last_page_in_session).and_return(true)
    flexmock(controller).should_receive(:alien_profile_administration_permission).and_return(true)    
  end
  
  describe "get 'main'" do
    it 'should be successful' do
      get 'main'
      response.should be_success
    end
    
    it 'should render main template' do
      get 'main'
      response.should render_template('main')
    end
    
    it 'should set board_langs variable' do
      flexmock(controller).should_receive(:get_board_langs).and_return('en')
      @usr = User.first
      get 'main'
      assigns(:board_langs).should_not be_nil
    end
    
    it 'should be redirected to main' do
      flexmock(@usr).should_receive(:update_attribute).and_return(true)
      flexmock(@usr).should_receive(:valid?).and_return(true)
      assigns[:usr] = @usr
      get 'main', {:users => {:forum_lang => 'en', :timezone => 'UTC'}}, {:last_page => '/profile/main'}
      response.should redirect_to(:action => 'main')
    end
  end

  describe "get 'personal'" do
    it 'should be successful' do
      get 'personal'
      response.should be_success
    end
    
    it 'should render personal template' do
     # debugger
      get 'personal'
      response.should render_template('personal')
    end
    
    it 'should set board_langs variable' do
      get 'personal'
      assigns(:board_langs).should_not be_nil
    end
    
    it 'should be redirected to personal' do
      @usr.should_receive(:update_attribute).and_return(true)
      @usr.should_receive(:isvalidate).and_return(false)
      @usr.should_receive(:isvalidate=)
      assigns[:usr] = @usr
      #debugger
      get 'personal', {:users => {:forum_lang => 'en', :timezone => 'UTC'}}, {:last_page => '/profile/main'}
      response.should redirect_to(:action => 'personal')
    end
  end
  
  describe "get 'communication'" do
    it 'should be successful' do
      get 'communication'
      response.should be_success
    end
    
    it 'should render communication template' do
      get 'communication'
      response.should render_template('communication')
    end
    
    it 'should be redirected to communication' do
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:valid?).and_return(true)
      @usr.should_receive(:isvalidate).and_return(false)
      get 'communication', {:users => {}}, {:last_page => '/profile/communication'}
      response.should redirect_to(:action => 'communication')
    end
  end
  
  describe "get 'individual'" do
    it 'should be successful' do
      get 'individual'
      response.should be_success
    end
    
    it 'should render individual template' do
      get 'individual'
      response.should render_template('individual')
    end
    
    it 'should be redirected to individual' do
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      @usr.should_receive(:isvalidate).and_return(false)
      get 'individual', {:users => {}}, {:last_page => '/profile/individual'}
      response.should redirect_to(:action => 'individual')
    end
  end
  
  describe "get 'view'" do
    it 'should be successful' do
      get 'view'
      response.should be_success
    end
    
    it 'should render view template' do
      get 'view'
      response.should render_template('view')
    end
    
    it 'should be redirected to view' do
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      @usr.should_receive(:isvalidate).and_return(false)
      @usr.should_receive(:isvalidate=).and_return(false)
      #@usr.
      get 'view', {:users => {}}, {:last_page => '/profile/view'}
      response.should redirect_to(:action => 'view')
    end
  end
  
  describe "get 'private'" do
    it 'should be successful' do
      get 'private'
      response.should be_success
    end
    
    it 'should render private template' do
      get 'private'
      response.should render_template('private')
    end
    
    it 'should be redirected to private' do
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      @usr.should_receive(:isvalidate).and_return(false)
      get 'private', {:users => {}}, {:last_page => '/profile/private'}
      response.should redirect_to(:action => 'private')
    end
  end
  
  describe "get 'avatar'" do
    it 'should be successful' do
      get 'avatar'
      response.should be_success
    end
    
    it 'should render avatar template' do
      get 'avatar'
      response.should render_template('avatar')
    end
    
    it 'should be redirected to avatar' do
      @usr.should_receive(:save_avatar).and_return(true)
      @usr.should_receive(:errors).and_return([])
      get 'private', {:users => {}}, {:last_page => '/profile/avatar'}
      response.should redirect_to(:action => 'avatar')
    end
  end

  describe "get 'messages'" do
    before(:each) do
      @usr.should_reveive(:posts).and_return([flexmock(:model, Post), flexmock(:model, Post)])
      flexmock(Topic).should_receive(:paginate).and_return(true)
    end
    
    it 'should be successful' do
      get 'messages'
      response.should be_success
    end
    
    it 'should render messages template' do
      get 'messages'
      response.should render_template('messages')
    end
  end
  
  describe "get 'rem_avatar'" do
    it 'should be redirected to avatar' do
      
    end
  end
  
  describe "get 'change_pass'" do
    it 'should be successful' do
      get 'change_pass'
      response.should be_success
    end
    
    it 'should render change_pass template' do
      get 'change_pass'
      response.should render_template('change_pass')
    end
    
    it 'should be redirected to main' do
#      @usr.should_receive(:proper_password?).and_return(true)
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      flexmock(@usr).should_receive(:change_pass).and_return(true)
      flexmock(@usr).should_receive(:proper_password?).and_return(true)
      debugger
      assigns[:usr] = @usr
      get 'change_pass', {:users => {}}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'change_email'" do
    it 'should be successful' do
      get 'change_email'
      response.should be_success
    end
    
    it 'should render change_email template' do
      get 'change_email'
      response.should render_template('change_email')
    end
    
    it 'should be redirected to main' do
#      @usr.should_receive(:proper_password?).and_return(true)
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      assigns[:usr] = @usr
      get 'change_email', {:users => {}}
      response.should redirect_to(:action => 'main')
    end
  end
  
  describe "get 'administration'" do
    before(:each) do
      flexmock(controller).should_receive(:alien_profile_administration_permission).and_return(true)
    end
    
    it 'should be success' do
      get 'administration'
      response.should be_success
    end
    
    it 'should render administration template' do
      get 'administration'
      response.should render_template('administration')
    end
    
    it 'should be redirected to administration' do
      @usr.should_receive(:subpartitions).and_return(flexmock(:model, Subpartition).should_receive(:clear).and_return(true))
      @usr.should_receive(:errors).and_return([])
      get 'administration', {:profile => {}}, {:last_page => '/profile/administration'}
      response.should redirect_to(:action => 'administration')
    end
  end
  
  describe "get 'change_alien_password'" do
    it 'should be success' do
      get 'change_alien_password'
      response.should be_success
    end
    
    it 'should render change_alien_password template' do
      get 'change_alien_password'
      response.should render_template('change_alien_password')
    end
    
    it 'should be redirected to change_alien_password' do
      @usr.should_receive(:update_attributes).and_return(true)
      @usr.should_receive(:errors).and_return([])
      get 'administration', {:profile => {}}, {:last_page => '/profile/change_alien_password'}
      response.should redirect_to(:action => 'change_alien_password')
    end
  end
end
