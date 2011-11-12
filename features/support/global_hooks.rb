# if defined? ActionController::Base
#     cookies[:orientisrbb_session] = Digest::MD5.hexdigest(User.find_by_name('admin') + Time.now.utc.to_s)
# end

# Session.create(:session_id => cookies[:orientisrbb_session],
#                             :data => ActiveRecord::SessionStore::Session.marshal(Hash[:save_session => true, :user_id => User.find_by_name('admin').id]))
# 
  World(ShowMeTheCookies)
  Before do
    #debugger
    Configs.find_by_name('redirect_timeout').update_attribute(:value, '0')
  end

  Before('@announce') do
      @announce = true
#      Dir.glob(File.join(File.dirname(__FILE__), '../../db/seeds.rb')).each {|f| require f }
  end

Before do
  #debugger
  #Dir.glob(File.join(File.dirname(__FILE__), '../../db/seeds.rb')).each {|f| require f }
end
  
at_exit do
    Session.delete_all
end