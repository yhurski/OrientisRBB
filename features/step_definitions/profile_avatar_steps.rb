Given /^User on the avatar page of his profile$/ do
  visit '/profile/avatar'
end


When /^he upload avatar$/ do
  attach_file('user_avatar', File.join(RAILS_ROOT, 'features/step_definitions/test_avatar.png'))
end

Then /^he should see avatar image on avatar page$/ do
  page.has_selector?('img')
end


When /^he removes avatar$/ do
  visit '/profile/rem_avatar'
end

Then /^he should see "(.+)"$/ do |msg|
  page.has_content?(msg)
end