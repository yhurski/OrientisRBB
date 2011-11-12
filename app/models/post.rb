class Post < ActiveRecord::Base
  belongs_to  :topic
  belongs_to :user, :foreign_key => 'poster_id'
  has_many :reports

  has_many :attach_files, if Configs.get_config('attach_allow_orphans').to_bool
    {:dependent => :nullify}
  else
    {:dependent => :delete_all}
  end

  validates_acceptance_of :remove_acceptance
  validates_presence_of :message
  validate :contains_only_capital_letters

  validates_length_of :poster, :in => 3..25, :allow_nil => false, :allow_blank => false, :if => :poster_is_guest
  validates_email_format_of :poster_email, :if => :poster_is_guest, :local_length => 40, :domain_length => 30

  validates_each :poster, :if => :poster_is_guest do |record,name,value|
    record.errors.add(name, I18n.t(:double_name)) if User.exists?(["name = ?", value])
  end
      
  def max_posted
    attributes['max_posted']
  end
    
  def count_posted_ip
    attributes['count_posted_ip']
  end
    
  def update_post params, ip, session, topic_id=0, was_edited = false
    topic_id = params[:id].to_i if topic_id == 0
    return false unless Topic.exists?(topic_id)
    if User.exists?(session[:user_id])
      users_post = User.find(session[:user_id])
    else
      users_post = User.get_guest unless User.get_guest.nil?
    end
    if was_edited
      self.update_attributes(:message => params[:answer_message], :edited => Time.now.utc, :edited_by => users_post.id)#session[:user_id])
    else
      self.update_attributes(:topic_id => topic_id, :poster => (params[:anonym_name] || users_post.name), :poster_id => users_post.id,
        :message => params[:answer_message], :posted => Time.now.utc, :edited => 0, :edited_by => 0, :poster_ip => ip)
    end
    self
  end
 
  def self.save_post params, ip, session, topic_id=0
    topic_id = params[:id].to_i if topic_id == 0
    if User.exists?(session[:user_id])
      users_post = User.find(session[:user_id])
    else
      users_post = User.get_guest unless User.get_guest.nil?
    end
    return if users_post.nil?
    Post.create(:topic_id => topic_id, :poster => (params[:anonym_name] || users_post.name), :poster_id => users_post.id, :message => params[:answer_message],
      :posted => Time.now.utc, :edited => 0, :edited_by => 0, :poster_ip => ip, :poster_email => params[:anonym_email])
  end
    
  def is_user_post user=nil
    if user == nil
      false
    else
      user.id == self.poster_id
    end
  end
        
  def poster_is_guest
    self.user.group_id == Group.get_guest.id
  end
    
  #TODO: test
  def update_post_dependent
    self.topic.update_attributes(:last_poster => self.poster, :last_post_id => self.id, :last_post => self.posted)
    self.topic.num_replies_inc
    self.topic.subpartition.num_posts_inc
  end
    
private
  #TODO: add a regexp localization
  #example model:  /^([0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*[\75-\77]*[A-Z]+[0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*)+$/
  def contains_only_capital_letters#\123-\255\91-\96
    if ! Configs.get_config('allow_capitals').to_bool && ! (self.message =~ /^([0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*[\75-\77]*[A-Z]+[0-9\32-\64\[\]\/\^\_\`\{\}\|\~]*)+$/).nil?
      self.errors.add('message', I18n.t(:posts_with_cap))
    end
  end
end
