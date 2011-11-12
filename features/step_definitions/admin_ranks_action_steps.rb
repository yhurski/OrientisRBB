Given /^admin on the ranks page of admin panel$/ do
  visit '/admin/ranks'
end


When /^he adds rank title and rank post amount$/ do
  fill_in 'ranks_rank', :with => 'My new rank'
  fill_in 'ranks_num_of_posts', :with => '4567'
end

When /^save it in db$/ do
  click_button 'Add new rank'
end

Then /^new record of rank should be appeared$/ do
  Rank.find(:all, :conditions => ['rank = ? and num_of_posts = ?', 'My new rank', '4567']).should_not be_empty
  page.has_field?('ranks_rank', :with => 'My new rank').should be_true
  page.has_field?('ranks_num_of_posts', :with => '4567').should be_true
end


When /^he changes title or post amount of rank$/ do
  begin
    @title = Faker::Lorem.word
    @amount = rand(10_000)
  end while(Rank.exists?(['rank = ? and num_of_posts = ?', @title, @amount]))
end

When /^he renews page$/ do
  visit '/admin/ranks'
end

Then /^updated pair of words should be appeared in db$/ do
  page.has_field?('censors_source_word', :with => @title).should be_true
  page.has_field?('censors_dest_word', :with => @amount).should be_true
end


When /^he presses Remove button$/ do
  @total_amount = Rank.count
  click_button 'Remove'
end

Then /^pair of rank title - post amount should be deleted$/ do
  Rank.count.should be_eql(@total_amount - 1)
end