require 'spec_helper'

describe Post do  
  before(:all) do
     #@user = FactoryGirl.create(:user)
     #debugger
     @partition = FactoryGirl.create(:partition)
     @subpartition = FactoryGirl.create(:subpartition, :partition_id => @partition.id)
     @topic = FactoryGirl.create(:topic, :subpartition_id => @subpartition.id)
     @post = FactoryGirl.create(:post, :topic_id => @topic.id)#, :user => FactoryGirl.build(:user))
  end
  
  it { should belong_to :topic }
  it { should belong_to :user }
  it { should have_many :reports }
  it { should have_many :attach_files }
  if Configs.get_config('attach_allow_orphans').to_bool
    it { should have_many(:attach_files).dependent(:nullify) }
  else
    it { should have_many(:attach_files).dependent(:delete_all) }
  end
  
  it 'should validate new records' do
     @partition.should be_valid
     @subpartition.should be_valid
     @topic.should be_valid
     @post.should be_valid
   end
   
   #it { should validate_acceptance_of(:remove_acceptance) }
   it 'should validate presence of msg' do
     if(@post.poster_is_guest) 
       should validate_presence_of(:message)
     end
   end
   
   it 'should ensure length of poster' do
     if(@post.poster_is_guest)
       should ensure_length_of(:poster).is_at_least(3).is_at_most(25)
     end
   end
   
   it 'should validate uniqueness of guest username' do
       post = Post.save_post({:answer_message => 'tra da ta', :anonym_name => FactoryGirl.create(:user).name, :anonym_email => '2hk6k@hellmail.grd'}, '22.33.44.55', {}, @topic.id) 
       post.errors.on(:poster).should_not be_blank
   end
   
   it 'should validate email format' do
      post = Post.save_post({:answer_message => 'tra da ta', :anonym_name => Faker.letterify('?????'), :anonym_email => Faker.letterify('???' * (rand(10)+1))}, '22.33.44.55', {}, nil) 
      post.errors.on(:poster_email).should_not be_blank
   end
   
   it 'should validate full email length' do
      post = Post.save_post({:answer_message => 'tra da ta', :anonym_name => Faker.letterify('?????'), :anonym_email => Faker.letterify('?' * 71)}, '22.33.44.55', {}, nil) 
      post.errors.on(:poster_email).should_not be_blank
  end
    
  it 'should validate message with capital letters' do
    unless Configs.get_config('allow_capitals').to_bool
      post = Post.save_post({:answer_message => 'tra da ta'.upcase, :anonym_name => Faker.letterify('?????'), :anonym_email => '2hk6k@hellmail.grd'}, '22.33.44.55', {}, nil) 
      post.errors.on(:message).should_not be_blank
    end
  end
   
   it 'should contain max_posted attribute' do
     @post.should be_respond_to :max_posted
   end
   
   it 'should contain count_posted_ip attribute' do
     @post.should be_respond_to :count_posted_ip
   end

  # it 'should have attachment' do
 #    should validate_attachment_presence(:attach)
   #end
  #it{should validate_attachment_presence(:attach_file)}

   it 'should create new' do
     post_count = Post.count
     new_post = Post.save_post({:answer_message => '123 234 jjj'}, '22.33.44.55', {:user_id => @topic.user.id}, @topic.id)
     new_post.message.should  be_eql('123 234 jjj')
     new_post.poster_ip.should  be_eql('22.33.44.55')
     new_post.is_user_post(@topic.user).should be_true
     new_post.should be_valid
     Post.all.should have(post_count + 1).posts
   end
   
   it 'should be updated by guest' do
   #   @post.update_post({:answer_message => 'tra da ta', :anonym_name => '2hk6k', :anonym_email => '2hk6k@hellmail.grd'}, '22.33.44.55', {}, @post.topic.id).should be_true
   #   debugger
   #   @post.user.group.guest?.should be_true
      pending
   end
   
   it 'should return false with nil topic_id' do
   #  debugger
     @post.update_post({:answer_message => 'tra da ta', :anonym_name => '2hk6k', :anonym_email => '2hk6k@hellmail.grd'}, '22.33.44.55', {}, nil).should be_false
   end
   
  it "should create a new instance given valid attributes" do
    #Post.create!(@valid_attributes)
    pending
  end
end
