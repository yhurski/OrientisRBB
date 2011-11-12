Given /^admin on the maintenance of admin panel$/ do
  visit '/admin/maintenance'
end

When /^he enables maintenance mode and writes message$/ do
  check 'maintenance_enable'
  fill_in 'maintenance_message', :with => 'My maintenance message'
  click_button 'Save'
end

Then /^he should see page with message and enabled maintenance mode$/ do
  page.has_checked_field?('maintenance_enable')
  page.has_field?('maintenance_message', :with => 'My maintenance message')
end


Given /^forum swithed in maintenance mode$/ do
  Configs.find_by_name('enable_maintenance').update_attribute(:value, '1') 
  visit '/forum/logout'
end

When /^user comes to forum_page$/ do
  visit '/forum/main'
end

Then /^he should see maintenance message$/ do
  page.should have_content('My maintenance message')
end