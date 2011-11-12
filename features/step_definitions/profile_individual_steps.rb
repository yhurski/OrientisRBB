Given /^User on the individual page of his profile$/ do
  visit '/profile/individual'
end

When /^he changes signature$/ do
  fill_in 'users_signature', :with => 'my new signature'
end

When /^he pushes Save button$/ do
  click_button 'Save'
end

Then /^he should see new values of signature$/ do
  page.has_field?('users_signature', :with => 'my new signature')
  page.should have_content('my new signature')
end