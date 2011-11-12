Given /^User on the private page of his profile$/ do
  visit '/profile/private'
end

When /^he changes private$/ do
  choose 'users_howshowemail_0'
end

When /^user clicks on Save button$/ do
  click_button 'Save'
end

Then /^he should see new values of private$/ do
  page.has_checked_field?('users_howshowemail_0')
end