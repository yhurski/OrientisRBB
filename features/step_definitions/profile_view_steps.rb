Given /^User on the view page of his profile$/ do
  visit '/profile/view'
end

When /^he changes view$/ do
  select 'Default_blue', :from => 'users_forum_style'
  
  uncheck 'users_smiles_to_img'
  uncheck 'users_show_users_sign'
  uncheck 'users_show_img_inmess'
  uncheck 'users_show_img_insign'
  
  fill_in 'users_themes_per_page', :with => '15'
  fill_in 'users_posts_per_page', :with => '15'
end

When /^user pushes Save button$/ do
  click_button 'Save'
end

Then /^he should see new values of view$/ do
  page.has_select?('users_forum_style', :selected => 'Default_blue')
  
  page.has_no_checked_field?('users_smiles_to_img')
  page.has_no_checked_field?('users_show_users_sign')
  page.has_no_checked_field?('users_show_img_inmess')
  page.has_no_checked_field?('users_show_img_insign')
  
  page.has_field?('users_themes_per_page', :with => '15')
  page.has_field?('users_posts_per_page', :with => '15')
end