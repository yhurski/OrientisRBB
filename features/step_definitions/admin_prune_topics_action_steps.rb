Given /^admin on the prune_topics page of admin panel$/ do
  @partition = Partition.create(:title => 'my partition', :part_pos => rand(99_999_999))
  @subpartition = Subpartition.create(:partition_id => @partition.id, :title => 'my subpartition', :part_pos => rand(99_999_999), :num_posts => 1, :num_topics => 1)
  @topic = Topic.create(:subpartition_id => @subpartition.id, :poster => 'admin', :title => 'my topic', :first_post_id => 1,
                                  :last_post => Time.now.utc - 3.days, :last_post_id => 1, :last_poster => 'admin', :num_views => 1, 
                                  :num_replies => 1, :closed => false, :sticky => false, :moved_to => 0, :poster_id => 1)
  Group.all.each{|group| ForumPerm.create(:group_id => group.id, :subpartition_id => @subpartition.id, :read_forum => true, :post_replies => true, :post_topics => true)}
  visit '/admin/prune_topics'
end


When /^he enters days ago greater than age in days of the topic last post$/ do
  select @subpartition.title, :from => 'prune_subpartition'
  fill_in 'prune_days_old', :with => '100'
  click_button 'Delete'
end

Then /^he should see page with message about absence topics$/ do
  page.should have_content("There are no topics that are as old as you have specified. Please decrease the value of 'Days old' and try again.")
end


When /^he enters number of days$/ do
  select @subpartition.title, :from => 'prune_subpartition'
  fill_in 'prune_days_old', :with => '2'
  click_button 'Delete'
end

When /^answers to confirmation question positive$/ do
  click_button 'Destroy'
end

Then /^topics should be removed$/ do
  Topic.exists?(@topic.id).should be_false
end