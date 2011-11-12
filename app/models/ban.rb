class Ban < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'ban_creator'

  validates_length_of :username, :in => 3..25, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of :username, :allow_nil => true, :allow_blank => true
  validate :ban_user_must_exists
  validates_existence_of :user
  validates_format_of :ip, :with => /^(\d{1,3}\.){3}\d{1,3}$/, :allow_nil => true, :allow_blank => true
  validates_email_format_of :email, :allow_nil => true, :allow_blank => true
  validates_length_of :message, :maximum => 255, :allow_nil => true, :allow_blank => true

  def self.drop_banned
    curr_date = Time.now.utc.strftime('%Y-%m-%d')
    all_banned = find(:all, :conditions => ["expire <> 0"])
    all_banned.each do |ban|
      if curr_date >= ban.expire
        Ban.destroy ban
      end
    end
  end
    
private

  def ban_user_must_exists
    unless username.blank?
      unless User.exists?(["name = ?", username])
        errors.add(:username, I18n.t(:not_exist))
      end
    end
  end
  
end
