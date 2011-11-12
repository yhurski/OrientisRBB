require 'spec_helper'

describe User do
  before(:all) do
    @user = FactoryGirl.create(:user)
  end
  
  it 'should be valid' do
    @user.should be_valid
  end
  
  it { should have_many(:posts) }
  it { should have_many(:topics) }
  it { should have_many(:bans) }
  it { should have_many(:attach_files) }
  it { should belong_to(:group) }
  it { should have_many(:reports) }
  it { should have_many(:bans) }
  it { should have_and_belong_to_many(:subpartitions) }
  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_least(3).is_at_most(25) }
  it { should validate_format_of(:name).with('/^\w{3,25}$/i') }
  it { should validate_uniqueness_of(:name).with_message('Such name has already been taken. Choice another username.') }
  it { should ensure_length_of(:email).is_at_least(8).is_at_most(70) }
#  it { should validate_format_of(:web).with("/^http[s]?:\/\/.+$/i").with_message('Web-site field is invalid. Site address must be preceded with protocol http(s)://') }
  it { should validate_format_of(:web).with(Faker::Internet.http_url).with_message('Web-site field is invalid. Site address must be preceded with protocol http(s)://') }
#  it { should validate_attachment_size(:avatar).less_than((1500000)) }
  it { should ensure_inclusion_of(:howshowemail).in_range('0', '1', '2').with_low_message('Undefined value of a how show email field').with_high_message('Undefined value of a how show email field') }
  it { should ensure_inclusion_of(:dst).in_range(true,false).with_low_message('Undefined value of a daylight saving field').with_high_message('Undefined value of a daylight saving field')  }
  it { should ensure_length_of(:timezone).is_at_least(3).is_at_most(80) }
  it { should ensure_length_of(:jabber).is_at_least(0).is_at_most(50) }
  it { should validate_numericality_of(:icq) }
  it { should ensure_length_of(:icq).is_at_least(4).is_at_most(15) } 
  it { should ensure_length_of(:msn).is_at_least(0).is_at_most(50) }
  it { should ensure_length_of(:aim).is_at_least(0).is_at_most(50) }
  it { should ensure_length_of(:yahoo).is_at_least(0).is_at_most(30) }
  it { should ensure_length_of(:realname).is_at_least(0).is_at_most(100) }
  it { should ensure_length_of(:location).is_at_least(0).is_at_most(100) }
  it { should ensure_length_of(:web).is_at_least(0).is_at_most(255) }
  it { should ensure_length_of(:themes_per_page).is_at_most(4) }
  it { should ensure_length_of(:posts_per_page).is_at_most(4) }
  it { should validate_numericality_of(:themes_per_page) }
  it { should validate_numericality_of(:posts_per_page) }
  it { should validate_presence_of(:last_visit) }
  it { should ensure_length_of(:title).is_at_least(0).is_at_most(50) }
  it { should ensure_length_of(:signature).is_at_least(0).is_at_most(Configs.get_config('maxchar_signature').to_i) }
  
  it 'should validate amount of lines in signature' do
    max_amount = Configs.get_config('maxlines_signature').to_i
    usr = FactoryGirl.create(:user, :signature => Faker::Lorem.words(max_amount+1).join('\r\n') << '\r\n')
    usr.errors.on(:signature).should_not be_blank
  end
  
  it 'should validate registration_ip timeout' do
    pending #need timecop
    t_out = Configs::REGISTRATION_FLOOD_TIMEOUT.seconds
    FactoryGirl.create(:user, :registration_ip => @user.registration_ip, :regdatetime => @user.regdatetime + rand(t_out)).errors.on(:registration_ip).should_not be_blank
  end
  
  it 'should deny registration for user with banned e-mail' do
    ban = FactoryGirl.create(:ban, :username => @user.name, :email => @user.email)
    #debugger
    new_user = FactoryGirl.build(:user, :email => @user.email)
    new_user.save
    unless Configs.get_config('email_registration').to_bool
      new_user.errors.invalid?(:email).should be_true
    else
      new_user.errors.invalid?(:email).should be_false
    end
    ban.delete
  end
  
  it 'should deny to change e-mail to banned' do
    ban_me = FactoryGirl.create(:user)
    ban = FactoryGirl.create(:ban, :username => ban_me.name, :email => ban_me.email, :ban_creator => @user.id)
    unless Configs.get_config('email_registration_dub').to_bool
      @user.update_attributes(:email => ban.email)
      @user.errors.invalid?(:email).should be_true
    else
      @user.update_attributes(:email => ban.email)
      @user.errors.invalid?(:email).should be_true
    end
    ban.delete
  end

  it 'should change password on update' do
    @user.isvalidate = false
    old_pwd = @user.passwd
    @user.update_attributes(:passwd => Faker.letterify('??????'))
    @user.passwd.size.should be_eql(32)
    @user.passwd.should_not be_eql(old_pwd)
    @user.isvalidate = true
  end

  describe 'named scopes' do
    #there is only three attributes for a while
    before(:all) do
      @cols = ['name', 'email', 'last_visit']
    end

    it 'should order by asc by random attribute' do
      col = @cols.random_element
      User.order_by_asc(col).last.should be_eql(User.find(:all, :order => "#{col} asc").last)
    end

    it 'should order by desc by random attribute' do
       col = @cols.random_element
       #debugger
       User.order_by_desc(col).last.should be_eql(User.find(:all, :order => "#{col} desc").last)
    end

    it 'should return all record for a given group' do
      grp = Group.all.random_element
      User.all_from_group(grp.id).size.should be_eql(User.find(:all, :conditions => ['group_id = ?', grp.id]).size)
    end
  end

  it 'should contain plain_password instance method' do
    @user.should be_respond_to(:plain_password)
  end

  it 'should contain new_email instance method' do
    @user.should be_respond_to(:new_email)
  end

  it 'should check if user is admin' do
    @user.admin?.should be_eql(@user.group.admin?)
  end

  #maybe it;s redundant method
  it 'should check if user logined' do
    @user.logined?(nil).should be_false
    @user.logined?({}).should be_false
    @user.logined?({:user_id => 1}).should be_true
  end

  it 'should return user status' do
    if Configs.get_config('allow_rank').to_bool &&  Rank.exists?(["num_of_posts <= ?", @user.numposts])
      @user.get_user_status.should be_eql(Rank.find(:all, :conditions => ["num_of_posts <= ?", self.numposts]).max{|r1,r2| r1.numposts <=> r2.numposts})
    else
      if @user.group.g_set_title
        if @user.title
          @user.get_user_status.should be_eql(@user.title)
        end
      else
         @user.get_user_status.should be_eql(@user.group.title_name)
      end
    end
  end

  it 'should check whether user online' do
    @user.online?.should be_eql(Online.user_exists?(@user) && (Online.find_by_user_object(self).last_visit + Configs.get_config('online_timeout').to_i.seconds >= Time.now.utc))
  end

  it 'should return user online status' do
    if @user.online?
      @user.get_online_status.should be_eql('Onlline')
    else
      @user.get_online_status.should be_eql('Offline')
    end
  end

  it 'should check whether website defined' do
    @user.is_website_defined.should_not be_eql(@user.web.blank?)
  end

  it 'should check whether location defined' do
    @user.is_location_defined.should_not be_eql(@user.location.blank?)
  end

  it 'should return false for inccorect avatar parameter' do
    @user.save_avatar(nil).should be_false
    @user.save_avatar('123').should be_false
    @user.save_avatar({}).should be_false
  end

  it 'should save avatar' do
    tempfile = Tempfile.new('ava.jpg')
    tempfile.puts('a' * 50)
    @user.save_avatar({:avatar => tempfile})
    @user.avatar.size.should_not be_nil
    @user.avatar.size.should be_eql(@user.avatar_file_size)
    tempfile.close(true)
  end

  it 'should check whether attachment allowed' do
    @user.is_attachment_allowed.should be_eql(@user.group.attach_allow_upload)
  end

  it 'should return max amount of allowed attachments for one post' do
    @user.max_attach_files_count.should be_eql(@user.group.attach_files_per_post)
  end

  it 'should check a clean user password' do
    usr = FactoryGirl.create(:user, :passwd => '123456')
    #debugger
    usr.proper_password?('123456').should be_true
  end

  it 'should return nil for illegal timedate_convert parameter' do
    @user.timedate_convert(nil).should be_nil
    @user.timedate_convert(false).should be_nil
    @user.timedate_convert(123).should be_nil
    @user.timedate_convert('123').should be_nil
  end

  it 'should convert timedate from utc to user location' do
    utc = Time.now.utc
    user_timedate = utc.in_time_zone(@user.timezone)
    unless @user.dst
      user_timedate = user_timedate.isdst ? user_timedate - 1.hour : user_timedate
    end
    @user.timedate_convert(utc).should be_eql(user_timedate.strftime(@user.date_format + ' ' + @user.time_format))
  end

  it 'should return nil for illegal user_date_to_utc parameter' do
    random_input = Faker.bothify('#'*rand(3) + '?'*rand(3) + '#'*rand(3) + '?'*3)
    @user.user_date_to_utc(random_input).nil?.should be_eql(Time.zone.parse(random_input).nil?)
  end

  it 'should convert timedate from user location to utc' do
    utc = Time.now.utc
    user_timedate = @user.timedate_convert(utc)
    @user.user_date_to_utc(user_timedate).strftime(@user.date_format + ' ' + @user.time_format).should be_eql(utc.strftime(@user.date_format + ' ' + @user.time_format))
  end

  it 'should return a number for posts pagination' do
    usr = FactoryGirl.build(:user, :posts_per_page => nil)
    usr.pagination_posts_amount.should be_eql(Configs.get_config('postsperpage'))
    @user.pagination_posts_amount.should be_eql(@user.posts_per_page)
  end

  it 'should return a number for topics pagination' do
    usr = FactoryGirl.build(:user, :themes_per_page => nil)
    usr.pagination_topics_amount.should be_eql(Configs.get_config('topperpage'))
    @user.pagination_topics_amount.should be_eql(@user.themes_per_page)
  end

  it 'should return a last registered user' do
    User.get_last_registered.should be_eql(User.find(:all, :conditions => ['group_id <> ?', Group.get_guest.id]).max{|u1, u2| u1.regdatetime <=> u2.regdatetime})
  end

  it 'should check whether user is moderator' do
    @user.is_moderator.should be_eql(@user.group.g_moderator)
  end

  it 'should check whether user is allowed to moderate other users' do
    @user.allow_moderation?.should be_eql(@user.is_moderator && @user.group.g_mod_edit_users)
  end

  it 'should change number of posts by one' do
    lambda{ @user.numposts_inc }.should change(@user, :numposts).by(1)
  end

  it 'should change last_post timedate to current' do
    curr = Time.now.utc
    @user.set_last_post
    @user.last_post.should be_eql(curr)
  end

  it 'should check whether convert text smiles to image smiles' do
    if Configs.get_config('show_graphsmiles').to_bool
      @user.is_smiles_to_img.should be_eql(@user.smiles_to_img)
    else
      @user.is_smiles_to_img.should be_false
    end
  end

  it 'should check whether show signature' do
    if Configs.get_config('allow_signature').to_boo
      @user.is_show_signature.should be_eql(@user.show_users_sign)
    else
      @user.is_show_signature.should be_false
    end
  end

  it 'should return a guest record' do
    User.get_guest.should be_eql(User.find_by_group_id(Group.get_guest.id))
  end

  it 'should have avatar' do
    @user.should be_respond_to(:avatar)
  end

  it 'should clear avatar_ attributes' do
    @user.clear_avatar
    @user.avatar_file_name.should be_nil
    @user.avatar_content_type.should be_nil
    @user.avatar_file_size.should be_nil
    @user.avatar_updated_at.should be_nil
  end
  
  it 'should crypt password' do
    usr = FactoryGirl.create(:user, :passwd => '123456')
    usr.passwd.size.should be_eql(32)
    usr.plain_password.should be_eql('123456')
  end
  
  it 'should nullify some attributes' do
    usr = FactoryGirl.create(:user, :jabber => (' ' * rand(10)), :icq => (' ' * rand(10)), :msn => (' ' * rand(10)), :aim => (' ' * rand(10)),
                                                 :yahoo => (' ' * rand(10)), :realname => (' ' * rand(10)), :location => (' ' * rand(10)), :web => (' ' * rand(10)),
                                                 :signature => (' ' * rand(10)))
    usr.jabber.should be_nil
    usr.icq.should be_nil
    usr.msn.should be_nil
    usr.aim.should be_nil
    usr.yahoo.should be_nil
    usr.realname.should be_nil
    usr.location.should be_nil
    usr.web.should be_nil
    usr.signature.should be_nil
  end

  it 'should return md5 hash of string with salt' do
    User.get_md5_passwd_hash('123456', 'salt').should be_eql(Digest::MD5.hexdigest(Digest::MD5.hexdigest('123456')+Digest::MD5.hexdigest('salt')))
  end


  describe 'private methods' do

    it 'should check whether to perform verifying of registration' do
      @user.send(:verify_by_email).should be_eql(Configs.verify_by_email)
    end

    it 'should check whether to perform registration with dublicate email' do
      @user.send(:dub_email_allowed?).should be_eql(Configs.get_config('email_registration_dub').to_bool)
    end

    it 'should make error if signature line amount is greater than allowed' do
      allowed_amount = Configs.get_config('maxlines_signature').to_i
      @user.signature = Faker::Lorem.words(allowed_amount).join("\r\n")# << '\r\n'
      @user.send(:signature_line_count)
      @user.errors.invalid?(:signature).should be_false
      @user.signature = Faker::Lorem.words(allowed_amount + 1).join("\r\n")# << '\r\n'
      @user.send(:signature_line_count)
      @user.errors.invalid?(:signature).should be_true
    end

    describe 'perform_full_search method' do
      before(:all) do
      #  @string_attr = [:name, :title, :realname, :location, :signature, :adminnote, :email, :web, :jabber, :icq, :msn, :aim, :yahoo]
        @string_attr_length = {:name => 25, :title => 50,:realname => 100, :location => 100,:signature => 65535, :adminnote => 255, :email => 70, :web => 255,
                                      :jabber => 50, :icq => 15, :msn => 50, :aim => 30, :yahoo => 30}
        @date_attr = [:search_postafter, :search_postbefore, :search_regafter, :search_regbefore]
        @num_attr = [:search_moreposts, :search_lessposts]
      end

      it 'should return nil for wrong parameter' do
        User.send(:perform_full_search, nil).should be_nil
        User.send(:perform_full_search, 123456).should be_nil
        User.send(:perform_full_search, '123456').should be_nil
        User.send(:perform_full_search, {}).should be_nil
      end

      it 'should return all users' do
        User.send(:perform_full_search, {'search_name' => '*'}).size.should be_eql(User.find(:all, :conditions => ['group_id <> ?', Group.get_guest.id]).size)
      end
      
      it 'should return all users by random string_attr' do
        random_attr = @string_attr_length.keys.random_element
        User.send(:perform_full_search, {random_attr.to_s => '*'}).size.should be_eql(User.find(:all, :conditions => ['group_id <> ?', Group.get_guest.id]).size)
      end
      
      it 'should return error if parameter length is greater than allowed' do
        random_attr = @string_attr_length.keys.random_element
        random_attr_size = @string_attr_length[:random_attr]
        User.send(:perform_full_search, {random_attr.to_s => ('a'*(random_attr_size + 1))}).should be_kind_of(Hash)
        User.send(:perform_full_search, {random_attr.to_s => ('a'*(random_attr_size + 1))}).should has(random_attr)
      end

      it 'should return something by random attribute' do
        random_attr = @string_attr_length.keys.random_element
        random_user = (User.all - Group.get_guest.to_a).random_element
        User.send(:perform_full_search, {random_attr.to_s => random_user.send(random_attr)}).size.should be_eql(User.find(:all, :conditions => ["group_id <> ? and #{random_attr} = ?", Group.get_guest.id, random_user.send(random_attr)]).size)
      end
      
      it 'should return something by one or more attributes' do
        bottom = rand(@string_attr_length.keys.size)
        top = rand(@string_attr_length.keys.size)
        bottom,top = top, bottom if bottom > top
        random_attrs = @string_attr_length.keys.slice(bottom,top)
        random_user = (User.all - Group.get_guest.to_a).random_element
        params_hash = {}
        condition_string = ''
        random_attrs.each do |attr|
          params_hash[attr.to_s] = random_user.send(attr)
          condition_string << " #{attr} = #{random_user.send(attr)} and"
        end
        condition_string << " group_id <> #{Group.get_guest.id}"
        User.send(:perform_full_search, params_hash).size.should be_eql(User.find(:all, :conditions => [condition_string]).size)
      end
      
      it 'should return something by numb attribute' do
        random_attr = @num_attr.random_element
        random_user = (User.all - Group.get_guest.to_a).random_element
        User.send(:perform_full_search, {random_attr.to_s => random_user.send(random_attr)}).size.should be_eql(User.find(:all, :conditions => ["group_id <> ? and #{random_attr} = ?", Group.get_guest.id, random_user.send(random_attr)]).size)
      end
      
      it 'should return error for illegal number parameter' do
        random_attr = @num_attr.random_element
        #input_str = Faker.letterify('???')
        user_input = rand(2).to_bool ? Faker.numerify('#'*12) : Faker.letterify('???')
        User.send(:perform_full_search, {random_attr.to_s => user_input}).should be_kind_of(Hash)
        User.send(:perform_full_search, {random_attr.to_s => user_input}).should has(random_attr)
      end
      
      it 'should return something for timedate attribute' do
        random_attr = @date_attr.random_element
        user_input = Time.now.utc#rand(2).to_bool ? Faker.numerify('#'*12) : Faker.letterify('???')
        User.send(:perform_full_search, {random_attr.to_s => user_input}, @user).size.should be_eql(User.find(:all, :conditions => ["group_id <> ? and #{random_attr} = ?", Group.get_guest.id, @user.user_date_to_utc(user_input)]).size)
      end
      
      it 'should return error for illegal timedate parameter' do
        random_attr = @date_attr.random_element
        user_input = Faker.letterify('???')
        User.send(:perform_full_search, {random_attr.to_s => user_input}, @user).should be_kind_of(Hash)
        User.send(:perform_full_search, {random_attr.to_s => user_input}, @user).should has(random_attr)
      end

      it 'should return all in random group' do
        random_group_id = (Group.all.map(&:id) - Group.get_guest.id.to_a).random_element
        User.send(:perform_full_search, {:search_name => '*', :s_usergroup => random_group_id}).to_a.should =~ User.find(:all, :conditions => ["group_id = ?", random_group_id]).to_a
      end
      
      it 'should return all unverified (registered but no logined) users' do
        User.send(:perform_full_search, {:search_name => '*', :s_usergroup => -1}).to_a.should =~ User.find(:all, :conditions => ["group_id <> ? and last_visit is null", Group.get_guest.id]).to_a
      end

      it 'should return nil for empty search field(s)' do
        random_param = (@string_attr_length.keys + @date_attr + @num_attr).random_element
        User.send(:perform_full_search, {random_param.to_s => ''}).should be_nil
      end
      
      it 'should return ordered records' do
        order_by = ['name', 'email', 'last_post', 'regdatetime', 'numposts']
        order_sort = ['asc', 'desc']
        order_by_rnd = order_by.random_element
        order_sort_rnd = order_sort.random_element
        User.send(:perform_full_search, {:search_name => '*', :s_orderby => order_by_rnd, :s_ordersort => order_sort_rnd}).to_a.last.should be_eql(User.find(:all, :conditions => ["group_id <> ?", User.get_guest.id], :order => "#{order_by_rnd} #{order_sort_rnd}"))
      end
  
      it 'should check whether registration allowed with banned e-mail' do
        if @user.isvalidate
          @user.send(:regist_with_banned_email).should be_eql(Configs.get_config('email_registration').to_bool)
        else
          @user.send(:regist_with_banned_email).should be_true
        end
      end
      
      it 'should check whether registration allowed with dublicate e-mail' do
        if @user.isvalidate
          @user.send(:regist_with_dub_email).should be_eql(Configs.get_config('email_registration_dub').to_bool)
        else
          @user.send(:regist_with_dub_email).should be_true
        end
      end

    end
  end
  
  
end
