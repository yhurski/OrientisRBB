Given /^admin on the features page of admin panel$/ do
  visit '/admin/features'
end

When /^he changes features parameters$/ do
  check 'allow_search'
  check 'allow_rank'
  check 'allow_cens'
  check 'allow_jumpmenu'
  check 'show_version'
  check 'show_usersonline'
  
  check 'show_quickpost'
  check 'allow_topicssubsc'
  check 'allow_guestpost'
  check 'allow_usersdot'
  check 'show_views'
  check 'allow_postcount'
  check 'show_userinfo'
  
  check 'allow_bbc'
  check 'allow_bbc_img'
  check 'show_graphsmiles'
  check 'allow_bbcurl'
  check 'allow_capitals'
  check 'allow_capitalssubj'
  fill_in 'quote_depth', :with => '5'
  
  check 'allow_signature'
  check 'allow_bbcsignature'
  check 'allow_bbcimgsignature'
  check 'convert_smilestoicon'
  check 'allow_capitalssign'
  fill_in 'maxchar_signature', :with => '500'
  fill_in 'maxlines_signature', :with => '5'
  
  check 'allow_avatars'
  fill_in 'dir_avatars', :with => '/home/public/avatars'
  fill_in 'maxwidth_avatars', :with => '150'
  fill_in 'maxheight_avatars', :with => '200'
  fill_in 'maxsize_avatars', :with => '50_000'
end

When /^Save button was pressed$/ do
  click_button 'Save'
end

Then /^forum feature values should be saved$/ do
  page.has_checked_field?('allow_search')
  page.has_checked_field?('allow_rank')
  page.has_checked_field?('allow_cens')
  page.has_checked_field?('allow_jumpmenu')
  page.has_checked_field?('show_version')
  page.has_checked_field?('show_usersonline')
  
  page.has_checked_field?('show_quickpost')
  page.has_checked_field?('allow_topicssubsc')
  page.has_checked_field?('allow_guestpost')
  page.has_checked_field?('allow_usersdot')
  page.has_checked_field?('show_views')
  page.has_checked_field?('allow_postcount')
  page.has_checked_field?('show_userinfo')
  
  page.has_checked_field?('allow_bbc')
  page.has_checked_field?('allow_bbc_img')
  page.has_checked_field?('show_graphsmiles')
  page.has_checked_field?('allow_bbcurl')
  page.has_checked_field?('allow_capitals')
  page.has_checked_field?('allow_capitalssubj')  
  page.has_field?('quote_depth', :with => '5')
  
  page.has_checked_field?('allow_signature')
  page.has_checked_field?('allow_bbcsignature')
  page.has_checked_field?('allow_bbcimgsignature')
  page.has_checked_field?('convert_smilestoicon')
  page.has_checked_field?('allow_capitalssign')  
  page.has_field?('maxchar_signature', :with => '500')
  page.has_field?('maxlines_signature', :with => '5')
  
  page.has_checked_field?('allow_avatars')
  page.has_field?('dir_avatars', :with => '/home/public/avatars').should be_true
  page.has_field?('maxwidth_avatars', :with => '150')
  page.has_field?('maxheight_avatars', :with => '200')
  page.has_field?('maxsize_avatars', :with => '50_000')
end