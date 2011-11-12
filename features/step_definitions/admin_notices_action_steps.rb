Given /^admin on the notices page of admin panel$/ do
  visit '/admin/notices'
end

When /^he changes notices parameters$/ do
  uncheck 'notices_allow_notice'
  fill_in 'notices_notice_title', :with => 'my new notice'
  fill_in 'notices_notice_message', :with => 'my new notice message'
end

When /^he saves notices values$/ do
  click_button 'Save'
end

Then /^forum notices values should be updated$/ do
  page.has_no_checked_field?('notices_allow_notice').should be_true
  page.has_field?('notices_notice_title', :with => 'my new notice').should be_true
  page.has_field?('notices_notice_message', :with => 'my new notice message').should be_true
end