Given /^admin on the manage_partitions page$/ do
  visit '/admin/manage_partitions'
end


When /^he adds new forum$/ do
  begin
    @forum_title = Faker::Lorem.sentence
    @forum_pos = rand(1000)
  end while Partition.exists?(['title = ? or part_pos = ?', @forum_title, @forum_pos])
  fill_in 'add_title', :with => @forum_title
  fill_in 'add_part_pos', :with => @forum_pos.to_s
end

When /^he pushes Add forum button$/ do
  click_button 'Add forum'
end

Then /^he should see new editable forum record on manage_partitions page$/ do
  page.has_field?('update_title', :with => @forum_title)
  page.has_field?('update_part_pos', :with => @forum_pos)
end


When /^admin edits forum$/ do
  begin
    @forum_title = Faker::Lorem.sentence
    @forum_pos = rand(1000)
  end while Partition.exists?(['title = ? or part_pos = ?', @forum_title, @forum_pos])
  fill_in 'update_title', :with => @forum_title
  fill_in 'update_part_pos', :with => @forum_pos.to_s
end

When /^he pushes Update$/ do
  click_button 'Update'
end

Then /^he should see updated forum record on manage_partitions page$/ do
  page.has_field?('update_title', :with => @forum_title)
  page.has_field?('update_part_pos', :with => @forum_pos)
end


When /^admin choices forum from list$/ do
  @del_partition = Partition.first
  select @del_partition.title, :from => 'delete_partition'
end

When /^he presses Delete button$/ do
  click_button 'Delete'
end

Then /^choices forum should be removed$/ do
  page.has_no_field?('update_title', :with => @del_partition.title)
  page.has_no_field?('update_part_pos', :with => @del_partition.part_pos)
end
