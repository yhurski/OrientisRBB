Given /^admin on the censoring page of admin panel$/ do
  visit '/admin/censoring'
end


When /^he adds censoring and replacement words$/ do
  fill_in 'censors_source_word', :with => 'source_word'
  fill_in 'censors_dest_word', :with => 'destination_word'
end

When /^save it$/ do
  click_button 'Add'
end

Then /^new pair of words should be appeared on page$/ do
  page.has_field?('censors_source_word', :with => 'source_word').should be_true
  page.has_field?('censors_dest_word', :with => 'destination_word').should be_true
end


When /^he changes censoring or replacement word$/ do
  fill_in 'censors_source_word', :with => 'new_source_word'
  fill_in 'censors_dest_word', :with => 'new_destination_word'
end

When /^update it$/ do
  click_button 'Update'
end

Then /^updated pair of words should be appeared on page$/ do
  page.has_field?('censors_source_word', :with => 'new_source_word').should be_true
  page.has_field?('censors_dest_word', :with => 'new_destination_word').should be_true
end


When /^he presses Remove button$/ do
  click_button 'Remove'
end

Then /^pair of words should be deleted$/ do
  page.has_no_field?('censors_source_word', :with => 'new_source_word').should be_true
  page.has_no_field?('censors_dest_word', :with => 'new_destination_word').should be_true
end