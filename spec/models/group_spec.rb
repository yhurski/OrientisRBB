require 'spec_helper'

describe Group do
  before(:all) do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
  end

  it { should have_many(:forum_perms) }
  it { should have_many(:users) }
  it { should validate_numericality_of(:g_post_flood) }
  it { should validate_numericality_of(:g_search_flood) }
  it { should validate_numericality_of(:g_email_flood) }

  it 'should validate attach parameters if attach is allowed' do
    if @group.send(:is_attach_allowed)
      should validate_numericality_of(:attach_upload_max_size)
      should validate_numericality_of(:attach_files_per_post)
    end
  end

  it 'should get admin group' do
    Group.get_admin.should be_eql(Group.find_by_is_admin(true))
  end

  it 'should get guest group' do
    Group.get_guest.should be_eql(Group.find_by_is_guest(true))
  end

  it 'should return true if group is administration' do
    @group.admin?.should be_eql(Group.find(:first, :conditions => ['is_admin = ?', true]).id == @group.id)
  end

  it 'should return true if group is guest' do
    @group.guest?.should be_eql(Group.find(:first, :conditions => ['is_guest = ?', true]).id == @group.id)
  end

  it 'should return true if group is moderator' do
    @group.moderator?.should be_eql(@group.g_moderator)
  end

  it 'should return group id by user' do
    #for guest
    Group.get_user_group_id(nil).should be_eql(Group.find_by_is_guest(true).id)
    #for registered user
    Group.get_user_group_id(@user).should be_eql(@user.group.id)
  end

  it 'should return default group for newly registrated users' do
    Group.get_default_group.should be_eql(Group.find(Configs.get_config('default_group').to_i))
  end

  it 'should return true if post has less attachments than was allowed for current user group' do
    @group.attachment_allowed_yet?(-1).should be_false
    @group.attachment_allowed_yet?(0).should be_true
    current_post_attach_count = rand(20) + 1
    @group.attachment_allowed_yet?(current_post_attach_count).should be_eql(@group.attach_files_per_post - current_post_attach_count > 0 ? true : false)
  end


end
