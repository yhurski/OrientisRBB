#background
Given /^User on the search page$/ do
  visit "/addendum/search"
   # r = FactoryGirl.create(:rank)
  ####
   # p = FactoryGirl.create_list(:partition, 2)
    # s = FactoryGirl.create_list(:subpartition, 30)
  ####
  # FactoryGirl.create(:post, :id => 2, :message => 'hooy')
    FactoryGirl.create(:subpartition, :id => 777)
# nr = Rank.create(:rank => 'ololo', :num_of_posts => 20)
  debugger
  #r.should be_respond_to(:num_of_posts)
#  get_cookie('orientisrbb_session')
#    cookies[:user_id] = 1
  # debugger
#  p.size.should  be_eql(Partition.all.size - 1)
end


When /^I am press search button$/ do
       click_button "Search"
end

Then /^I should come to search results page$/ do
      page.should have_content('There are no results.')  
end


When /^I fill in a keyword text field with \"(.+)\"$/ do |keyword|
     fill_in 'keywords', :with => keyword     
end

When /^I press search button$/ do
     click_button 'Search'  
end    

Then /^I should see result post$/ do
    RestClient.get 'http://localhost:3000/addendum/search', {:cookies => {:orientisrbb_session => '318047bdb99731b6ffbb5ad7689958bf'}}
    page.should have_content 'Test message'   
    show_me_the_cookies
    # save_and_open_page
end    
    
