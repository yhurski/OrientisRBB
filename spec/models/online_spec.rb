require 'spec_helper'

describe Online do
  before(:all) do
    @user = FactoryGirl.create(:user)
    #debugger
    @online = FactoryGirl.create(:online, :user_id => @user.id, :last_visit =>  Time.now.utc - rand(100).minutes)
  end

  it 'should return all online users' do
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    Online.guests.to_a.size.should be_eql(Online.find(:all, :conditions => ["user_id = ? and (last_visit > ? or last_visit = ?)", User.get_guest.id, online_time_line, online_time_line]).to_a.size)
  end
  
  it 'should return at least one online guest' do
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    FactoryGirl.create(:online, :user_id => User.get_guest.id, :last_visit => Time.now.utc)
    Online.guests.to_a.should have_at_least(1).onlines
  end
  
  it 'should return all registered users' do
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    Online.registered_users.to_a.size.should be_eql(Online.find(:all, :conditions => ["user_id <> ? and (last_visit > ? or last_visit = ?)", User.get_guest.id, online_time_line, online_time_line]).to_a.size)
  end
  
  it 'should return at least one registered user' do
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    FactoryGirl.create(:online, :user_id => User.get_guest.id, :last_visit => Time.now.utc)
    Online.registered_users.to_a.should have_at_least(1).onlines
  end
  
  it 'should return true if user is online' do
    new_user = FactoryGirl.create(:user)
    Online.user_exists?(new_user).should be_false
    Online.user_exists?(@user).should be_true
  end
  
  it 'should return nil for illegal parameter' do
    Online.find_by_user_object(nil).should be_nil
    Online.find_by_user_object(123456).should be_nil
    Online.find_by_user_object('123456').should be_nil
    Online.find_by_user_object({}).should be_nil
  end
  
  it 'should return online record if user is online' do
    new_user = FactoryGirl.create(:user)
    Online.find_by_user_object(new_user).should be_nil
    Online.find_by_user_object(@user).should be_eql(Online.find(:first, :conditions => ["user_id = ? and name = ?", @user.id, @user.name]))
  end
  
end
