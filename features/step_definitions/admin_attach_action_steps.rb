Given /^admin on the attach page of admin panel$/ do
  visit '/admin/attach'
end


When /^he changes attach settings$/ do
  check 'attach_disable_attach'
  check 'attach_allow_orphans'
  fill_in 'attach_always_deny', :with => ''
  check 'attach_disp_small'
  fill_in 'attach_small_height', :with => '150'
  fill_in 'attach_small_weight', :with => '150'
  
  check 'attach_use_icon'
end

When /^he saves attach values$/ do
  click_button 'Save'
end

Then /^attach values should be updated$/ do
  page.has_checked_field?('attach_disable_attach')
  page.has_checked_field?('attach_allow_orphans')
  page.has_field?('attach_always_deny', :with => '')
  page.has_checked_field?('attach_disp_small')
  page.has_field?('attach_small_height', :with => '150')
  page.has_field?('attach_small_weight', :with => '150')
  
  page.has_checked_field?('attach_use_icon')
end


When /^he adds new attach icon record$/ do
  fill_in 'add_icon_type', :with => 'abc'
  fill_in 'add_icon_file', :with => 'video.png'
end

When /^he saves$/ do
  click_button 'Save'
end

Then /^should appear new icon record on page$/ do
  Configs.get_config('attach_icon_ext').split(',').should include('abc')
  Configs.get_config('attach_icon_name').split(',').should include('video.png')
end


When /^he clears extension and file name fields of exist icon record$/ do
  fill_in 'icon_0', :with => ''
  fill_in 'iconfile_0', :with => ''
  @total_icons = Configs.get_config('attach_icon_ext').split(',').size
end

When /^he saves it$/ do
  click_button 'Save'
end

Then /^icon record should be removed$/ do
  Configs.get_config('attach_icon_ext').split(',').size.should be_eql(@total_icons - 1)
end