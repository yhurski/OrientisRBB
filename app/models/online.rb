class Online < ActiveRecord::Base
  def self.guests
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    self.find(:all, :conditions => ["user_id = ? and (last_visit > ? or last_visit = ?)", User.get_guest.id, online_time_line, online_time_line])
  end
    
  def self.registered_users
    online_time_line = Time.now.utc - Configs.get_config('online_timeout').to_i
    Online.find(:all, :conditions => ["user_id <> ? and (last_visit > ? or last_visit = ?)", User.get_guest.id, online_time_line, online_time_line])
  end
    
  def self.guests_count
    self.guests.count
  end
    
  def self.registered_users_count
    self.registered_users.count
  end
    
  def self.user_exists? user
    if user.instance_of? User
      Online.exists? ["user_id = ? and name = ? ", user.id, user.name]
    else
      false
    end
  end
    
  def self.find_by_user_object user
    if user.instance_of? User
      Online.find(:first, :conditions => ["user_id = ? and name = ?", user.id, user.name])
    else
      nil
    end
  end
      
  def self.find_by_ip remote_addr
    self.find(:first, :conditions => ["user_id = ? and name = ?", User.get_guest.id, remote_addr])
  end
end
