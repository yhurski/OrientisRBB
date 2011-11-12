Given /^admin on the registration page of admin panel$/ do
  visit '/admin/registration'
end

When /^he changes registration settings$/ do
  check 'allow_registration'
  check 'verify_registration'
  check 'email_registration'
  check 'email_registration_dub'
  check 'email_notify'
  choose 'email_default_0'
  
  check 'use_rules'
  fill_in 'rules_text', :with => 'my new registration rules text'
end

When /^he saves registration values$/ do
  click_button 'Save'
end

Then /^forum registration values should be updated$/ do
  page.has_checked_field?('allow_registration').should be_true
  page.has_checked_field?('verify_registration').should be_true
  page.has_checked_field?('email_registration').should be_true
  page.has_checked_field?('email_registration_dub').should be_true
  page.has_checked_field?('email_notify').should be_true
  page.has_checked_field?('email_default_0').should be_true
  
  page.has_checked_field?('use_rules').should be_true
  page.has_field?('rules_text', :with => 'my new registration rules text').should be_true
end