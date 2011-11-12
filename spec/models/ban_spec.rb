require 'spec_helper'

describe Ban do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @ban = FactoryGirl.create(:ban, :username => @user.name)
  end
  
  it { should belong_to(:user) }
  it { should ensure_length_of(:username).is_at_least(3).is_at_most(25) }
  it { should validate_uniqueness_of(:username) }
  it { should validate_format_of(:ip).with('/^(\d{1,3}\.){3}\d{1,3}$/') }
  it { should ensure_length_of(:message).is_at_most(255) }

  it 'should validate existence of username in User table' do
    new_user = FactoryGirl.build(:user)
    new_ban = FactoryGirl.build(:ban, :username => new_user.name)
    new_ban.save
    new_ban.errors.on(:username).should_not be_empty
  end
  
  it 'should drop banned users with setting expire date' do
    expired_users_amount = Ban.find(:all, :conditions => ["expire <> 0 and expire <= ?", Time.now.utc.strftime('%Y-%m-%d')]).to_a.size
    lambda{ Ban.drop_banned }.should change(Ban, :count).by(expired_users_amount)
  end
  
end
