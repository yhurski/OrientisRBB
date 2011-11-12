Given /^User on the user search page$/ do
  visit '/forum/users_list'
end

When /^I fill a username field with (.+)$/ do |username|
  #debugger
  fill_in "users[name]", :with => username
end

When /^I choice a user group by (.+)$/ do |user_group|
 # debugger
  select user_group, :from => "users_group"
end

When /^I choice a type of sort by (.+)$/ do |sorting|
  #   debugger
  select sorting, :from => "users[sorting]"
end

When /^I choice a type of order by (.+)$/ do |ordering|
  select ordering, :from => "users[order]"
end

Then /^I should see (.+)$/ do |result|
  #debugger
  page.should have_content(result)
end