require 'spec_helper'

describe Topic do
  before(:all) do
    @partition = FactoryGirl.create(:partition)
    @subpartition = FactoryGirl.create(:subpartition, :partition_id => @partition.id)
    @topic = FactoryGirl.create(:topic, :subpartition_id => @subpartition.id)
    @user = FactoryGirl.create(:user)
  end
  
  it { should belong_to(:subpartition) }
  it { should belong_to(:user) }
  it { should have_many(:posts).dependent(:delete_all) }
  it { should have_many(:reports) }
  it { should validate_presence_of(:title) }
  it { should ensure_length_of(:title).is_at_most(255) }

  it 'should have many attaches depending on "attach_allow_orphans" config value' do
    if Configs.get_config('attach_allow_orphans').to_bool
        should have_many(:attach_files).dependent(:nullify)
    else
        should have_many(:attach_files).dependent(:delete_all)
    end
  end
  
  it 'should validate title with capital letters' do
    unless Configs.get_config('allow_capitalssubj').to_bool
      @topic.update_attributes(:title, Faker::Lorem.words(4).join(' ').upcase)
      @topic.errors.on(:title).should be_eql('Topic title cannot contain only capital letters.')
    end
  end
  
  it 'should return true if post has only main post' do
    @topic.is_one_post.should be_true
    @topic.update_attributes(:last_post_id => FactoryGirl.create(:post, :topic_id => @topic.id))
    @topic.is_one_post.should be_false
  end
  
  it 'should return false for illegal parameter for user_topic? method' do
    @topic.user_topic?(nil).should be_false
    @topic.user_topic?(123456).should be_false
    @topic.user_topic?('123456').should be_false
    @topic.user_topic?(@partition).should be_false
  end
  
  it 'should return true if topic contains at least one post of user' do
    @topic.user_topic?(@user).should be_false
    @topic.user_topic?(@topic.user).should be_true
  end
  
  it 'should prune topics' do
    FactoryGirl.create_list(:topic, 5, :subpartition_id => @subpartition.id).each{|t| t.update_attribute(:last_post, (Time.now.utc - 30.days))}
    lambda{ Topic.prune_topics(30, @subpartition.id, @user) }.should change(Topic, :count).by_at_least(30)
  end
  
  it 'should return true if has attach' do
    @topic.has_attach?.should_not be_eql(@topic.attach_files.empty?)
  end
  
  describe 'save_topic method' do
    
    it 'should return nil for subpartition that do not exist in db' do
      subp_id = 1
      subp_id = rand(Faker.numerify('#'*rand(10)).to_i + 1) while Subpartition.exists?(subp_id)
      Topic.save_topic({:id => subp_id}, {}).should be_nil
    end
    
    it 'should create new topic' do
      lambda{ Topic.prune_topics({:id => @subpartition.id, :topic_title => Faker::Lorem.words(4).join(' ')}, {}) }.should change(Topic, :count).by(1)
    end
    
    it 'should create new topic by guest' do
      Topic.prune_topics({:id => @subpartition.id, :topic_title => Faker::Lorem.words(4).join(' ')}, {}).poster_id.should be_eql(User.get_guest.id)
    end
    
    it 'should create new topic by @user and with defined title' do
      new_topic = Topic.prune_topics({:id => @subpartition.id, :topic_title => 'title title title'}, {:user_id => @user.id})
      new_topic.poster.should be_eql(@user.name)
      new_topic.title.should be_eql('title title title')
    end
  
  end
  
  it 'should return last post (as a Post object)' do
    @topic.last_post_object.id.should be_eql(Post.find(@topic.last_post_id).id)
  end
  
  it 'should return first post (as a Post object)' do
    @topic.first_post_object.id.should be_eql(Post.find(@topic.first_post_id).id)
  end
  
  describe 'move_topic method' do
    
    it 'should return nil for subpartition that do not exist in db' do
      subp_id = 1
      subp_id = rand(Faker.numerify('#'*rand(10)).to_i + 1) while Subpartition.exists?(subp_id)
      Topic.move_topics(@topic.id.to_a, subp_id, true).should be_nil
    end
    
    it 'should create new redirecting topic' do
      new_subp = FactoryGirl.create(:subpartition, :partition_id => @partition.id)
      Topic.move_topics(@topic.id.to_a, new_subp, true)
      Topic.find(:first, :conditions => ['subpartition_id = ? and moved_to = ?', @topic.subpartition.id, @topic.id]).should_not be_nil
      Topic.move_topics(new_subp.topics.first, @topic.subpartition, false)
      
    end
    
  end
  
  it 'should return true if topic is moved' do
    @topic.is_moved(@subpartition.id).should be_eql(@topic.moved_to.to_bool && @subpartition.id != @topic.moved_to)
  end
  
  it 'should return true if topic is closed' do
    @topic.is_closed.should be_eql(@topic.closed.nil? || @topic.closed.to_bool)
  end
  
  it 'should increment number of replies by one' do
    lambda{ @topic.num_replies_inc }.should change(@topic, :num_replies).by(1)
  end
  
  it 'should return last user post' do
    @topic.get_last_user_post(@user).should be_eql(@topic.posts.find_all_by_poster_id(@user.id).to_a.max{|first, second| second.posted <=> first.posted })
  end
  
  
  
end
