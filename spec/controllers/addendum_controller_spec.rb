require 'spec_helper'

describe AddendumController do
  
  before(:all) do
    %x(rake db:seed RAILS_ENV=test) 
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
    @group_permissions = flexmock(:model, Group)
    @usr = flexmock(:model, User, :id => 1, :name => 'pupkin', :email => 'pupkin@gmail.com', :group => @group_permissions, :forum_style => 'default')
    @usr.should_receive(:attr).and_return(true)
  end
  
  before(:each) do
    session[:user_id] = 1
    flexmock(controller).should_receive(:search_permission).and_return(true)
    flexmock(controller).should_receive(:search_flood_timeout_check).and_return(true)
    flexmock(controller).should_receive(:put_search_time).and_return(true)
  end

  describe "GET 'search'" do
    it 'should be successful' do
      get 'search'
      response.should be_success
    end
    
    it 'should be redirected to message' do
      get 'search', {:act => 'search', :commit => 'search', :us_sortby => '0', :us_orderby => '0', :us_resultas => '0', :find_author => ' '}
      response.should redirect_to(:action => 'message')
    end
    
    it 'should render sresult template' do
      get 'search', {:act => 'search', :keywords => '*', :us_resultas => '0', :commit => 'search', :us_sortby => '0', :us_orderby => '0', :find_author => ' '}
      response.should render_template('sresult')
    end
    
    it 'should render sresult_titles template' do
      get 'search', {:act => 'search', :keywords => '*', :us_resultas => '1', :commit => 'search', :us_sortby => '0', :us_orderby => '0',  :find_author => ' '}
      response.should render_template('sresult_titles')
    end
  end
end
