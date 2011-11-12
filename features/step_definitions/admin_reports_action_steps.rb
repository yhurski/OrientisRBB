Given /^admin on the reports page of admin panel$/ do
  visit '/admin/reports'
end

When /^he adds new report direct into db$/ do
  Report.create(:post_id => 1, :topic_id => 1, :subpartition_id => 1, :user_id => 1, :created_at => Time.now.utc, :message => 'My new report')
end


Then /^he should see new report on page$/ do
  visit '/admin/reports'
  page.should have_content('My new report')
end


When /^he clicks on 'Select all' link and clicks on 'Update' button$/ do
  Report.all.each {|report| report.update_attributes(:readed_at => Time.now.utc, :readed_by => 1)}
end

Then /^report page should be empty$/ do
  visit '/admin/reports'
  page.should have_content('There are no reports to read')
end
