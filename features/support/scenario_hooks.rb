Before('@addendum_search') do
#  debugger
  Dir.glob(File.join(File.dirname(__FILE__), '../../db/seeds.rb')).each {|f| require f }
  visit '/forum/login'
 
  fill_in 'user_username', :with => 'admin'
  fill_in 'user_password', :with => 'admin'
  check  'user_save_session'
  click_button 'Enter'
end

After do |scenario|
#   Session.delete_all
end