require 'spec_helper'

describe Subpartition do
  before(:all) do
#    debugger
    @partition = FactoryGirl.create(:partition)
    #debugger
    @subpartition = FactoryGirl.create(:subpartition, :partition_id => @partition.id)
    @user = FactoryGirl.create(:user)
  end
  
  it { should belong_to(:partition) }
  it { should have_many(:forum_perms).dependent(:destroy) }
  it { should have_many(:topics).dependent(:destroy) }
  it { should have_many(:reports) }
  it { should have_and_belong_to_many(:users) }
  it { should ensure_length_of(:title)}#.is_at_most(255) }#.with_message('Title field have improper length') }
  it { should validate_numericality_of(:part_pos).with_message('It is not numerical value') }

  it 'should validate uniqueness of title on create' do
    #debugger
    new_subp = FactoryGirl.build(:subpartition, :partition_id => @partition.id, :title => @subpartition.title)
    new_subp.save
    new_subp.errors.on(:title).should_not be_empty#eql('You have already subpartition with such title')
  end
  
  it 'should validate uniqueness of title on update' do
    new_subp = FactoryGirl.build(:subpartition, :partition_id => @partition.id)
    new_subp.update_attributes(:title => @subpartition.title)
    new_subp.save
    new_subp.errors.on(:title).should_not be_empty#eql('You have already subpartition with such title')
  end
  
  it 'should validate uniqueness of part_pos on create' do
    new_subp = FactoryGirl.build(:subpartition, :partition_id => @partition.id, :part_pos => @subpartition.part_pos)
    new_subp.save
    new_subp.errors.on(:part_pos).should_not be_empty#eql('You already have subpartition with such position')
  end
  
  it 'should validate uniqueness of part_pos on update' do
    new_subp = FactoryGirl.build(:subpartition, :partition_id => @partition.id)
    new_subp.update_attributes(:part_pos => @subpartition.part_pos)
    new_subp.save
    new_subp.errors.on(:part_pos).should_not be_empty#eql('You already have subpartition with such position')
  end
  
  it 'should increment number of posts' do
    lambda{ @subpartition.num_posts_inc }.should change(@subpartition, :num_posts).by(1)
  end
  
  it 'should increment number of topics' do
    lambda{ @subpartition.num_topics_inc }.should change(@subpartition, :num_topics).by(1)
  end

  it 'should increment number of posts and topics' do
    posts = @subpartition.num_posts
    topics = @subpartition.num_topics
    @subpartition.new_topic_inc
    @subpartition.num_posts.should be_eql(posts + 1)
    @subpartition.num_topics.should be_eql(topics + 1)
  end

#  it 'should return last post' do
#    @subpartition.last_post.should
#  end
   it 'should set default permission' do
     @subpartition.set_default_perms
     debugger
     @curr_user_perms = @subpartition.forum_perms.find{ |perm| perm.group_id == @user.group.id }
     @curr_user_perms.read_forum.should be_eql(@user.group.g_read_board)
     @curr_user_perms.post_replies.should be_eql(@user.group.g_post_replies)
     @curr_user_perms.post_topics.should be_eql(@user.group.g_post_topics)
   end

end
