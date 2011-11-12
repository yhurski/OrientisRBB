require 'spec_helper'

describe AttachFile do
  before(:all) do
    @post = FactoryGirl.create(:post, :topic_id => 1)
    @attach = FactoryGirl.create(:attach_file, :user_id => @post.user.id, :post_id => @post.id, :topic_id => @post.topic.id)
  end
  
  it "should be valid attach" do
   @attach.should be_valid
  end
 
  it 'should belong to post' do
    @post.attach_files << @attach
    @post.attach_files.should have(1).attach_files
  end
  
  it 'should return nil for empty params[:attach]' do
   AttachFile.save_attach({:attach => nil}, @post.id, @post.user.group).should be_nil
  end
 
  it 'should return nil for absence post' do
    AttachFile.save_attach({:attach => {:attach => Tempfile}}, FactoryGirl.build(:post, :topic_id => 1).id, @post.user.group).should be_nil
  end
  
  it 'should return nil for absence group' do
    AttachFile.save_attach({:attach => {:attach => Tempfile}}, @post.id, FactoryGirl.build(:group)).should be_nil
  end
  
  it 'should return error message instead of saving attach' do
    @post.user.group.update_attribute(:attach_upload_max_size, 50.kilobytes) #if @post.user.group.attach_upload_max_size.to_bool
    tempfile = Tempfile.new('tempfile.txt')
    tempfile.puts('A' * 51.kilobytes)
    #emulate params[:attach]
    test_params = {:attach => {:attach => tempfile}}
    flexmock(test_params[:attach][:attach]).should_receive(:original_path).and_return('tempfile.txt')
   # flexmock(test_params[:attach][:attach]).should_receive(:content_type).and_return(MimeMagic.by_extension('txt').type)
    AttachFile.save_attach(test_params, @post.id, @post.user.group).should be_eql('Attachment size is greater than allowed')
    tempfile.close(true)
  end
  
  describe 'params_by method' do
    #create fake attaches without real files on a hard disk
    before(:all) do
      FactoryGirl.create_list(:attach_file, 150, :user_id => (rand(100) + 1), :post_id => (rand(100) + 1), :topic_id => (rand(100) + 1))
    end
    
    after(:all) do
      AttachFile.delete_all
    end
   
    def random_size
      Faker.numerify('#' * (rand(11) + 1)).to_i
    end
    
    def get_user
      User.all.random_element || @attach.user
    end

    def get_topic
      Topic.all.random_element || @attach.topic
    end

    it 'should contain filter_by method' do
      AttachFile.should be_respond_to(:filter_by)
    end
  
    it 'should return nil by filter_by method' do
      AttachFile.filter_by(nil).should be_nil
      AttachFile.filter_by(123).should be_nil
      AttachFile.filter_by('123').should be_nil
      AttachFile.filter_by({}).should be_nil
    end
  
    it 'should return all attaches' do
      AttachFile.filter_by({:attach => {:max_size => nil, :user => nil, :topic => nil}}).count.should be_eql(AttachFile.count)
    end
    
    it 'should filter by max_size parameter' do
      random_max_size = random_size                                   #"attach_file_size >= 0 and attach_file_size <= #{random_max_size}"
      AttachFile.filter_by({:attach => {:max_size => random_max_size}}).count.should be_eql(AttachFile.count)
    end
    
    it 'should filter  by min_size parameter' do
      random_min_size = random_size
      AttachFile.filter_by({:attach => {:min_size => random_min_size}}).count.should be_eql(AttachFile.count)
    end
    
    it 'should filter by min_size and max_size parameters' do
      random_max_size = random_size
      random_min_size = random_size
      if random_min_size > random_max_size
        AttachFile.filter_by({:attach => {:min_size => random_min_size, :max_size => random_max_size}}).count.should be_eql(AttachFile.count)
        random_max_size, random_min_size = random_min_size, random_max_size
      end
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :max_size => random_max_size}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between #{random_min_size} and #{random_max_size}"]).count)
    end
    
    it 'should filter by topic parameter' do
      topic = get_topic
      AttachFile.filter_by({:attach => {:topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["topic_id = ?", topic.id]).count)
    end
    
    it 'should filter by min_size and topic parameters' do
      random_min_size = random_size
      topic = get_topic
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["topic_id = #{topic.id}"]).count)
    end
    
    it 'should filter  by max_size and topic parameters' do
      random_max_size = random_size
      topic = get_topic
      AttachFile.filter_by({:attach => {:max_size => random_max_size, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between 0 and #{random_max_size} and topic_id = #{topic.id}"]).count)
    end
    
    it 'should filter by min_size, max_size and topic parameters' do
      random_max_size = random_size
      random_min_size = random_size
      topic = get_topic
      random_max_size, random_min_size = random_min_size, random_max_size if random_min_size > random_max_size
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :max_size => random_max_size, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between #{random_min_size} and #{random_max_size} and topic_id = #{topic.id}"]).count)
    end
    
    it 'should filter by user parameter' do
      user = get_user
      AttachFile.filter_by({:attach => {:user => user.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["user_id = ?", user.id]).count)
    end
    
    it 'should filter by min_size and user parameters' do
      random_min_size = random_size
      user = get_user
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :user => user.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["user_id = #{user.id}"]).count)
    end
    
    it 'should filter  by max_size and user parameters' do
      random_max_size = random_size
      user = get_user
      AttachFile.filter_by({:attach => {:max_size => random_max_size, :user => user.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between 0 and #{random_max_size} and user_id = #{user.id}"]).count)
    end
    
    it 'should filter by min_size, max_size and user parameters' do
      random_max_size = random_size
      random_min_size = random_size
      user = get_user
      random_max_size, random_min_size = random_min_size, random_max_size if random_min_size > random_max_size
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :max_size => random_max_size, :user => user.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between #{random_min_size} and #{random_max_size} and user_id = #{user.id}"]).count)
    end
    
    it 'should filter by topic and user parameters' do
      user = get_user
      topic = get_topic
      AttachFile.filter_by({:attach => {:user => user.id, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["user_id = ? and topic_id = ?", user.id, topic.id]).count)
    end
    
    it 'should filter by min_size, topic and user parameters' do
      random_min_size = random_size
      user = get_user
      topic = get_topic
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :user => user.id, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["user_id = ? and topic_id = ?", user.id, topic.id]).count)
    end
    
    it 'should filter by max_size, topic and user parameters' do
      random_max_size = random_size
      user = get_user
      topic = get_topic
      AttachFile.filter_by({:attach => {:max_size => random_max_size, :user => user.id, :topic => topic.id}}).count.should be_eql(AttachFile.find(:all, :conditions => ["attach_file_size between 0 and ? and user_id = ? and topic_id = ?", random_max_size, user.id, topic.id]).count)
    end
    
    it 'should filter by min_size, max_size, topic and user parameters' do
      random_min_size = random_size
      random_max_size = random_size
      user = get_user
      topic = get_topic
      random_max_size, random_min_size = random_min_size, random_max_size if random_min_size > random_max_size
      AttachFile.filter_by({:attach => {:min_size => random_min_size, :max_size => random_max_size, :user => user.id, :topic => topic.id}}).count.should be_eql(
                                AttachFile.find(:all, :conditions => ["attach_file_size between #{random_min_size} and #{random_max_size} and user_id = ? and topic_id = ?", user.id, topic.id]).count)
    end
    
    it 'should order results' do
      pending
      
    end
    
  end
  
  
end
