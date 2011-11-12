class Group <  ActiveRecord::Base
  has_many :forum_perms
  has_many :users 

  validates_numericality_of :g_post_flood
  validates_numericality_of :g_search_flood
  validates_numericality_of :g_email_flood
  validates_numericality_of :attach_upload_max_size,  :if => :is_attach_allowed
  validates_numericality_of :attach_files_per_post,  :if => :is_attach_allowed
 
  def self.get_admin
    find_by_is_admin(true)
  end
  
  def self.get_guest
    find_by_is_guest(true)
  end

  #TODO: test it
  def self.get_member
    find(:first, :conditions => ["is_moder_in_group <> 1 and is_guest <> 1 and is_admin <> 1"])
  end

  #TODO: test it
  def self.get_moder
    find(:first, :conditions => ["is_moder_in_group = 1"])
  end
 
  def admin?
    Group.find(:first, :conditions => ['is_admin = ?', true]).id == self.id
  end
  
  def guest?
    Group.find(:first, :conditions => ['is_guest = ?', true]).id == self.id
  end
  
  def moderator?
    self.g_moderator
  end
  
  def self.get_user_group_id(usr_object)
    usr_object.nil? ? find_by_is_guest(true).id : usr_object.group.id
  end
    
  def self.get_default_group  
    find(Configs.get_config('default_group').to_i)
  end
  
  def attachment_allowed_yet? current_post_attach_count
    return false if current_post_attach_count < 0
    return true if self.attach_files_per_post == 0
    self.attach_files_per_post - current_post_attach_count > 0 ? true : false
  end  
 
private

  def is_attach_allowed
    attach_allow_upload
  end
end