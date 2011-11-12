Given /^User on the communication page of his profile$/ do
  visit '/profile/communication'
end

When /^he changes jabber, icq, msn, aol im, yahoo msn$/ do
  fill_in 'users_jabber', :with => 'admin@jabber.org'
  fill_in 'users_icq', :with => '123456789'
  fill_in 'users_msn', :with => 'admin@msn.com'
  fill_in 'users_aim', :with => '645654654'
  fill_in 'users_yahoo', :with => '654654654'
end

When /^he clicks Save button$/ do
  click_button 'Save'
end

Then /^he should see new values of jabber, icq, msn, aol im, yahoo msn$/ do
  page.has_field?('users_jabber', :with => 'admin@jabber.org')
  page.has_field?('users_icq', :with => '123456789')
  page.has_field?('users_msn', :with => 'admin@msn.com')
  page.has_field?('users_aim', :with => '645654654')
  page.has_field?('users_yahoo', :with => '654654654')
end