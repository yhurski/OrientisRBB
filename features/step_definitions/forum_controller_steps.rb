Given /^Temp$/ do
#  visit '/forum/main'
  save_and_open_page
end

When /^I come to forum main page$/ do
  visit '/forum/main'
end

Then /^I should view at least test forum$/ do
  page.should have_content('Test forum')
  
end