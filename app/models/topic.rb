class Topic < ActiveRecord::Base
  cattr_reader :per_page
  belongs_to :subpartition, :foreign_key => 'subpartition_id'
  belongs_to :user, :foreign_key => 'poster_id'
  has_many :posts, :dependent => :delete_all
  has_many :reports
        
  validates_presence_of :title
  validates_length_of :title, :maximum => 255
  validate :contains_only_capital_letters
        
  if Configs.get_config('attach_allow_orphans').to_bool
    has_many :attach_files, :dependent => :nullify
  else
    has_many :attach_files, :dependent => :delete_all
  end

  def is_one_post
    self.first_post_id == self.last_post_id
  end
    
  def user_topic? user_obj
    return false if user_obj.nil? || ! user_obj.kind_of?(User)
    posts.map(&:user).include?(user_obj) ? true : false
  end
    
  def self.prune_topics(subpartition_id, days_old, user)
    topics = Topic.all.select{|t| user.user_date_to_utc(Time.now.utc) - t.last_post >= days_old.days}
    topics = topics.select{|t| t.subpartition_id == subpartition_id} if subpartition_id > 0 && Subpartition.exists?(subpartition_id)
    topics.each{|t| t.destroy}
  end
    
  def has_attach?
    !self.attach_files.empty?
  end
    
  def self.save_topic params, session
    return nil unless Subpartition.exists?(params[:id])
    if User.exists?(session[:user_id])
      users_topic = User.find(session[:user_id])
    else
      users_topic = User.get_guest unless User.get_guest.nil?
    end
    return nil if users_topic.nil?
    Topic.create(:subpartition_id => params[:id], :poster => (params[:anonym_name] || users_topic.name), :title => params[:topic_title],
      :first_post_id => 0, :last_post => Time.now.utc, :last_post_id => 0, :last_poster => (params[:anonym_name] || users_topic.name),
      :num_views => 1, :num_replies => 0, :poster_id => users_topic.id, :moved_to => 0)
  end
    
  def last_post_object
    Post.find(self.last_post_id)
  end
    
  def first_post_object
    Post.find(self.first_post_id)
  end
       
  def self.move_topics(selected_topics, move_to, allowed_redirect)
    allowed_redirect = allowed_redirect.to_bool unless allowed_redirect.nil? || allowed_redirect.kind_of?(TrueClass) || allowed_redirect.kind_of?(FalseClass)
    return nil unless move_to.to_bool && ! Subpartition.exists?(move_to)
    selected_topics.each_key do |topic_id|
      if Topic.exists?(topic_id)
        if allowed_redirect
          movable_topic = Topic.find(topic_id)
          Topic.create(:subpartition_id => movable_topic.subpartition_id, :poster => movable_topic.poster, :title => movable_topic.title, :first_post_id => 0,
            :last_post => movable_topic.last_post, :last_post_id => 0, :last_poster => 0,
            :num_views => 0, :num_replies => 0, :moved_to => movable_topic.id)
        end
        if Subpartition.find(move_to).topics.map(&:moved_to).include?(topic_id.to_i)
          Topic.find_by_moved_to(topic_id).destroy
        end
        Topic.update(topic_id, :subpartition_id => move_to)
      end
    end
  end
  
  def is_moved subpart_id
    return (self.moved_to.to_bool && subpart_id != self.moved_to)
  end
  
  def is_closed
    return true if self.closed.nil?
    self.closed.to_bool
  end
  
  def num_replies_inc
    self.increment!(:num_replies)
  end

  #TODO: remove it
  def  self.last_post topic_id
    Post.find(:all, :conditions => ["topic_id = ?", topic_id], :order => "posted asc")  &&  Post.find(:all, :conditions => ["topic_id = ?", topic_id], :order => "posted asc").last
  end
    
  def get_last_user_post user_obj
    self.posts.find_all_by_poster_id(user_obj.id).to_a.max{|first, second| second.posted <=> first.posted }
  end
  
  private
  #TODO: add a regexp localization
  #TODO:  refactor, it's almost same as one in Post class
  def contains_only_capital_letters
    if ! Configs.get_config('allow_capitalssubj').to_bool && ! (self.title =~ /^([0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*[\75-\77]*[A-Z]+[0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*)+$/).nil?
      self.errors.add('title', I18n.t(:cap_letters))
    end
  end
end
