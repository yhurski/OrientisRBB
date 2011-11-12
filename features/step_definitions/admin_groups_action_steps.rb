Given /^admin on the groups page of admin panel$/ do
  visit '/admin/groups'
end


Then /^he should see all group names on page$/ do
  Group.all.map(&:name).each do |name|
    page.should have_content(name)
  end
end


When /^he presses 'Create new group' button$/ do
  click_button 'Create new group'
end

When /^he sets some new group parameters$/ do
  fill_in 'group_name', :with => 'my_new_group'
  fill_in 'group_title_name', :with => 'My new group'
  
  fill_in 'group_g_post_flood', :with => '100'
  fill_in 'group_g_search_flood', :with => '100'
  fill_in 'group_g_email_flood', :with => '100'
end

When /^he presses 'Update' button$/ do
  click_button 'Update'
end

Then /^he should see new group name on page$/ do
  page.should have_content('my_new_group')
end


When /^he load edit_group page with default group$/ do
  @def_group = Configs.get_config('default_group')
  visit "/admin/editgroup?ident=#{@def_group}"
end

When /^he changes some parameters in default group$/ do
  fill_in 'group_title_name', :with => '123123123'
  fill_in 'group_g_post_flood', :with => '123'
  fill_in 'group_g_search_flood', :with => '123'
  fill_in 'group_g_email_flood', :with => '123'
  click_button 'Update'
end

Then /^he should see update values for default group$/ do
  visit "/admin/editgroup?ident=#{@def_group}"
  page.has_field?('group_title_name', :with => '123123123')
  page.has_field?('group_g_post_flood', :with => '123')
  page.has_field?('group_g_search_flood', :with => '123')
  page.has_field?('group_g_email_flood', :with => '123')
end


When /^he presses 'Set default group'$/ do
  click_button 'Set default group'
end

Then /^default group will be set$/ do
  page.has_select?('def_groups', :selected => Group.find(Configs.get_config('default_group')).name)
end