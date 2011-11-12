Given /^admin on the e-mail page of admin panel$/ do
  visit '/admin/email'
end

When /^he changes e-mail settings$/ do
  check 'smtp_ssl'
  fill_in 'admin_email', :with => 'admin@gmail.com'
  fill_in 'webmaster_email', :with => 'web_master@gmail.com'
  fill_in 'mailing_list', :with => 'first_user@mail.ua, second_user@mymail.org'
  
  fill_in 'smtp_address', :with => 'smtp.gmail.com'
  fill_in 'smtp_username', :with => 'smtp_username'
  fill_in 'smtp_password', :with => 'smtp_password'  
end

When /^he saves e-mail values$/ do
  click_button 'Save'
end

Then /^forum e-mail values should be updated$/ do
  page.has_checked_field?('smtp_ssl').should be_true
  page.has_field?('admin_email', :with => 'admin@gmail.com').should be_true
  page.has_field?('webmaster_email', :with => 'web_master@gmail.com').should be_true
  page.has_field?('mailing_list', :with => 'first_user@mail.ua, second_user@mymail.org').should be_true
  
  page.has_field?('smtp_address', :with => 'smtp.gmail.com').should be_true
  page.has_field?('smtp_username', :with => 'smtp_username').should be_true
  page.has_field?('smtp_password', :with => 'smtp_password').should be_true
end