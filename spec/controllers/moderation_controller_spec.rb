require 'spec_helper'

describe ModerationController do
  
  before(:all) do
    %x(rake db:seed RAILS_ENV=test) 
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
    @group_permissions = flexmock(:model, Group)
    @usr = flexmock(:model, User, :id => 1, :name => 'pupkin', :email => 'pupkin@gmail.com', :group => @group_permissions, :forum_style => 'default')
    @usr.should_receive(:attr).and_return(true)
  end
  
  before(:each) do
    session[:user_id] = 1
    flexmock(controller).should_receive(:allow_user_perform_action).and_return(true)
    flexmock(controller).should_receive(:get_drop_down_menu_data).and_return(true)
    flexmock(controller).should_receive(:create_forums_optgroup).and_return(true)
  end

  describe "get 'index'" do
    it 'should be redirect to message' do
      get 'index', {:commit => 'asdf123asdf'}
      response.should redirect_to(:action => 'message')
    end
    
    describe 'move' do
      before(:each) do
        flexmock(Subpartition).should_receive(:count).and_return(2)
      end
      
      it 'should render move template' do
        get 'index', {:commit => 'Move', :selected_topic => {'1' => '1'}, :id => 1}
        response.should render_template('move')
      end
      
      it 'should be redirected to moderate' do
        flexmock(Topic).should_receive(:move_topics).and_return(true)
        get 'index', {:commit => 'Move', :selected_topic => {'1' => '1'}, :id => 1, :moved_to => 2}
        response.should redirect_to(:action => 'moderate')
      end
    end
      
    describe 'delete' do
      it 'should render delete template' do
        get 'index', {:commit => 'Delete', :selected_topic => {'1' => '1'}, :id => 1}
        response.should render_template('delete')
      end
      
      it 'should be redirected to moderate' do
        subpart = flexmock(:model, Subpartition)
        subpart.should_ignore_missing
        flexmock(Subpartition).should_receive(:find).and_return(subpart)
        flexmock(Topic).should_receive(:destroy).and_return(true)
        get 'index', {:commit => 'Delete', :selected_topic => {'1' => '1'}, :id => 1, :delete_confirmation => true}
        response.should redirect_to(:action => 'moderate', :id => '1')
      end
    end
      
    describe 'merge' do
      it 'should be redirected to message' do
        get 'index', {:commit => 'Merge', :selected_topic => {'1' => '1'}}
        response.should redirect_to(:action => 'message')
      end
      
      it 'should be redirected to moderate' do
        post = flexmock(:model, Post)
        post.should_receive(:poster).and_return(Time.now.utc)
        topic = flexmock(:model, Topic)
        topic.should_receive(:first_post_object).and_return(post)
        flexmock(Topic).should_receive(:find).and_return([topic])
        flexmock(Topic).should_receive(:destroy).and_return(true)
        get 'index', {:commit => 'Merge', :selected_topic => {'1' => '1', '2' => '2'}}
        response.should redirect_to(:action => 'moderate')
      end
    end
    
    describe 'open' do
      it 'should be redirected to moderate' do
        get 'index', {:commit => 'Open', :selected_topic => {'1' => '1'}}, {:last_page => '/moderation/moderate'}
        response.should redirect_to(:action => 'moderate')
      end
    end
    
    describe 'close' do
      it 'should be redirected to moderate' do
        get 'index', {:commit => 'Close', :selected_topic => {'1' => '1'}}, {:last_page => '/moderation/moderate'}
        response.should redirect_to(:action => 'moderate')
      end
    end
    
    describe 'stick' do
      it 'should be redirected to forum/main' do
        flexmock(Topic).should_receive(:exists?).and_return(false)
        get 'index', {:commit => 'Stick', :selected_topic => {'1' => '1'}}, {:last_page => '/forum/main'}
        response.should redirect_to(:controller => 'forum', :action => 'main')
      end
    end
    
    describe 'unstick' do
      it 'should be redirected to forum/main' do
        flexmock(Topic).should_receive(:exists?).and_return(false)
        get 'index', {:commit => 'Unstick', :selected_topic => {'1' => '1'}}, {:last_page => '/forum/main'}
        response.should redirect_to(:controller => 'forum', :action => 'main')
      end
    end
    
    describe 'delete_selected_posts' do
      it 'should render delete_selected_posts template' do
        get 'index', {:delete_selected_posts => 'Delete', :selected_post => {'1' => '1'}}
        response.should render_template('delete_selected_post')
      end
      
      it 'should be redirected to forum/main' do
        flexmock(Array).should_receive(:include?).and_return(true)
        topic = flexmock(:model, Topic)
        topic.should_receive(:first_post_id).and_return(1000)
        post = flexmock(:model, Post)
        post.should_receive(:topic).and_return(topic)
        flexmock(Post).should_receive(:find).and_return(post)
        flexmock(Post).should_receive(:destroy).and_return(true)
        get 'index', {:delete_selected_posts => 'Delete', :delete_post_confirmation => true, :selected_post => {'1001' => '1001'}}, {:last_page => '/forum/main'}
        response.should redirect_to(:controller => 'forum', :action => 'main')
      end
    end
    
    describe 'split_selected_posts' do
      it 'should render split_selected_posts template' do
        get 'index', {:split_selected_posts => 'Split', :selected_post => {'1' => '1', '2' => '2'}}
        response.should render_template('split_selected_posts')
      end
      
      it 'should be redirected to message for selected post < 2' do
        get 'index', {:split_selected_posts => 'Split', :selected_post => {'1' => '1'}, :split_post_confirmation => true, :title => 'foo bar zoo'}
        response.should redirect_to(:action => 'message')
      end
    end
    
    describe 'delete_this_topic' do
      before(:each) do
        flexmock(Topic).should_receive(:find).and_return(flexmock(:model, Topic))
      end
      
      it 'should render delete_this_topic template' do
        get 'index', {:delete_this_topic => true, :selected_topic => '1'}
        response.should render_template('forum/delete_topic')
      end
      
      it 'should be redirected to /forum/view_posts' do
        get 'index', {:delete_this_topic => true, :selected_topic => '1', :delete_this_topic => 'Cancel'}
        response.should redirect_to(:controller => 'forum', :action => 'view_posts', :id => 1)
      end
    end
    
  end
  
end
