Given /^User on the personal page of his profile$/ do
  visit '/profile/personal'
end

When /^he changes email, realname, location, website$/ do
  fill_in 'users_email', :with => 'admin@gmail.com'
  fill_in 'users_realname', :with => 'Vasiliy Pupkin aka admin'
  fill_in 'users_location', :with => 'BY, Minsk'
  fill_in 'users_web', :with => 'http://pupkin.by'
end

When /^he goes down Save button$/ do
  click_button 'Save'
end

Then /^he should see new values in html elements$/ do
  page.has_field?('users_email', :with => 'admin@gmail.com')
  page.has_field?('users_realname', :with => 'Vasiliy Pupkin aka admin')
  page.has_field?('users_location', :with => 'BY, Minsk')
  page.has_field?('users_web', :with => 'http://pupkin.by')
end