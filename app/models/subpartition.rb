class Subpartition < ActiveRecord::Base
  belongs_to :partition
  has_many :forum_perms, :dependent => :destroy
  has_many :topics, :foreign_key => 'subpartition_id', :dependent => :destroy
  has_many :reports
  has_and_belongs_to_many :users

  validates_existence_of :partition
  validates_length_of :title, :maximum => 255, :allow_blank => false, :allow_nil => false
  validates_numericality_of :part_pos, :integer_only => true

  validates_each :title do |record, name, value|
    if record.id.nil?
      if Subpartition.exists?(["partition_id = ? and title = ?", record.partition_id, value])
        record.errors.add(name, I18n.t(:double_title))
      end
    else
      if Subpartition.exists?(["partition_id = ? and title = ? and id <> ?", record.partition_id, value, record.id])
        record.errors.add(name, I18n.t(:double_title))
      end
    end
  end

  validates_each :part_pos do |record, name, value|
    if record.id.nil?
      if Subpartition.exists?(["partition_id = ? and part_pos = ?", record.partition_id, value])
        record.errors.add(name, I18n.t(:double_position))
      end
    else
      if Subpartition.exists?(["partition_id = ? and part_pos = ? and id <> ?", record.partition_id, value, record.id])
        record.errors.add(name, I18n.t(:double_position))
      end
    end
  end

  def num_posts_inc
    self.increment!(:num_posts)
  end
  
  def num_topics_inc
    self.increment!(:num_topics)
  end
  
  def new_topic_inc
    self.num_posts_inc
    self.num_topics_inc
  end
  
  def set_default_perms
    Group.all.each do |group|
      self.forum_perms.create(:group_id => group.id, :read_forum => group.g_read_board, :post_replies => group.g_post_replies, :post_topics => group.g_post_topics)
    end
  end  
    
  #TODO: tests  
  def decrease_num_posts  topics_id_arr
    topics_id_arr.each do |topic_id|
      if Topic.exists?(topic_id)
        topic = Topic.find(topic_id)
        self.update_attributes(:num_posts => (self.num_posts - topic.posts.size))
      end
    end
  end
  
  def decrease_num_topics topic_id_arr
    topic_id_arr.delete_if{|topic_id| ! Topic.exists?(topic_id)}
    self.update_attributes(:num_topics => (self.num_topics - topic_id_arr.size))
  end
end
