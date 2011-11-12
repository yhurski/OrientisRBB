 Given /^User on the main page of his profile$/ do
   visit '/profile/main'
 end
 
 When /^he changes tz, dst, lang$/ do
   select 'Minsk', :from => 'users_timezone'
   check 'users_dst'
   select 'en', :from => 'users_forum_lang'
 end
 
 When /^he presses Save button$/ do
   click_button 'Save'
 end
 
 Then /^he should be redirected$/ do
   page.has_select?('users_timezone', :selected => 'Minsk (GMT+02:00)')
   page.has_checked_field?('users_dst')
   page.has_select?('users_forum_lang', :selected => 'en')
 end