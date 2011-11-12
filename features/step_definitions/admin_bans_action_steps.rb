Given /^admin on the bans page of admin panel$/ do
  visit '/admin/bans'
end


When /^he adds user name for ban and press 'Add ban' button$/ do
  @ban_me = User.find(:first, :conditions => ['group_id <> ? and group_id <> ?', Group.get_admin, Group.get_guest])
  fill_in 'banname', :with => @ban_me.name
end

When /^he should edit ban expiration date on add_edit_ban page$/ do
  click_button 'Add ban'
end

When /^he clicks on 'Save' ban button$/ do
  fill_in 'bans_expire', :with => Time.now.utc.to_s(:db).split(' ')[0]
  click_button 'Save'
end

Then /^new ban record should be appeared on bans page$/ do
  page.should have_content('Username to ban ' + @ban_me.name)
end


When /^he goes to add_edit_ban page for a existing user$/ do
  ban_me = User.find(:first, :conditions => ['group_id <> ? and group_id <> ?', Group.get_admin, Group.get_guest])
  @banned_user = Ban.create(:username => ban_me.name, :ip => ban_me.registration_ip, :email => ban_me.email, :ban_creator => '1')
  visit "/admin/bans/#{@banned_user.id}?act=edit"
end

When /^he adds ban message$/ do
  fill_in 'bans_message', :with => 'My ban message'
  click_button 'Save'
end

Then /^ban message for a banned user should be appeared in db$/ do
  Ban.find(@banned_user.id).message.should be_eql('My ban message')
end


When /^he presses Remove link for a banned$/ do
  ban_me = User.find(:first, :conditions => ['group_id <> ? and group_id <> ?', Group.get_admin, Group.get_guest])
  @banned_user = Ban.create(:username => ban_me.name, :ip => ban_me.registration_ip, :email => ban_me.email, :ban_creator => '1')
  visit "/admin/bans/#{@banned_user.id}?act=drop"
end

Then /^banned user should be removed from db$/ do
  Ban.exists?(@banned_user.id).should be_false
end