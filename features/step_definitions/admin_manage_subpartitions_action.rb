Given /^admin on the manage_subpartitions page$/ do
  visit '/admin/manage_subpartitions'
end


When /^admin adds new category$/ do
  begin
    @forum_title = Faker::Lorem.sentence
    @forum_pos = rand(1000)
  end while Partition.exists?(['title = ? or part_pos = ?', @forum_title, @forum_pos])
  fill_in 'add_title', :with => @forum_title
  fill_in 'add_part_pos', :with => @forum_pos.to_s
end

When /^he pushes Add category button$/ do
  click_button 'Add category'
end

Then /^he should see new category title on manage_subpartitions page$/ do
  page.should have_content(@forum_title)
end


Given /^admin on the edit_subpartitions page$/ do
#  @edit_subpartition = Subpartition.all.random_element
  visit "/admin/edit_subpartitions/#{Subpartition.all.random_element.id}"
end

When /^admin edits category data$/ do
  begin
    @forum_title = Faker::Lorem.sentence
    @forum_pos = rand(1000)
  end while Partition.exists?(['title = ? or part_pos = ?', @forum_title, @forum_pos])
  fill_in 'update_title', :with => @forum_title
  fill_in 'update_part_pos', :with => @forum_pos.to_s
  fill_in 'update_desc', :with => Faker::Lorem.sentences.join(' ')
end

When /^he save value by clicking Save button$/ do
  click_button 'Save'
end

Then /^he should see updated forum record on manage_subpartitions page$/ do
  page.should have_content(@forum_title)
end


When /^admin clicks on link for appropriate category$/ do
  @edit_subpartition = Subpartition.all.random_element
 # debugger
#  click_link("/admin/drop_subpartition/#{@edit_subpartition.id}")
  page.find('a[href="/admin/drop_subpartition/1"]').click
end

Then /^category should be removed$/ do
  page.should_not have_content(@edit_subpartition.title)
end