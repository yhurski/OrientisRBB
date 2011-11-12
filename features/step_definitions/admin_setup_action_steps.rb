Given /^admin on the setup page of admin panel$/ do
  visit '/admin/setup'
end

When /^he changes setup parameters$/ do
  fill_in 'board_title', :with => 'my board title'
  fill_in 'board_desc', :with => 'my board description'
  select 'Default_blue', :from => 'default_style'
  
  select 'en', :from => 'default_lang'
  select 'Hawaii (GMT-10:00)', :from => 'users_timezone'
  check 'dst'
  fill_in 'default_timeformat', :with => '%H:%M:%S'
  fill_in 'default_dateformat', :with => '%Y-%m-%d'
  
  fill_in 'visit_timeout', :with => '6'
  fill_in 'online_timeout', :with => '5'
  fill_in 'redirect_timeout', :with => '0'
  
  fill_in 'topperpage', :with => '10'
  fill_in 'postsperpage', :with => '10'
  fill_in 'topreview', :with => '10'
end

When /^Save button$/ do
  click_button 'Save'
end

Then /^he should see saved values in html elements$/ do
  page.has_field?('board_title', :with => 'my board title')
  page.has_field?('board_desc', :with => 'my board description')
  page.has_select?('default_style', :selected => 'Default_blue')
  
  page.has_select?('default_lang', :selected => 'en')
  page.has_select?('users_timezone', :selected => 'Hawaii (GMT-10:00)')
  page.has_no_checked_field?('dst')
  page.has_field?('default_timeformat', :with => '%H:%M:%S')
  page.has_field?('default_dateformat', :with => '%Y-%m-%d')
  
  page.has_field?('visit_timeout', :with => '6')
  page.has_field?('online_timeout', :with => '5')
  page.has_field?('redirect_timeout', :with => '0')
  
  page.has_field?('topperpage', :with => '10')
  page.has_field?('postsperpage', :with => '10')
  page.has_field?('topreview', :with => '10')
end