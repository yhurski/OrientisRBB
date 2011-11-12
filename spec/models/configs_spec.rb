require 'spec_helper'

describe Configs do
  before(:all) do
    @user = FactoryGirl.create(:user)
  end
  
  it 'should contain number regex' do
    Faker.numerify('#####').should match(Configs::NUMBER_REGEXP)
  end

  it 'should contain registration timeout' do
    Configs::REGISTRATION_FLOOD_TIMEOUT.should be_eql(60 * 60)
  end

  it 'should validate online_timeout' do
    rec = Configs.find_by_name('online_timeout')
    rec.update_attributes(:value => Faker.letterify('????'))
    rec.errors.on(:online_timeout).should_not be_blank
  end

  it 'should validate visit_timeout' do
    rec = Configs.find_by_name('visit_timeout')
    rec.update_attributes(:value => Faker.letterify('????'))
    rec.errors.on(:visit_timeout).should_not be_blank
  end

  it 'should contain online_timeout is less than visit_timeout' do
    visit_tm = Configs.find_by_name('visit_timeout').value.to_i
    rec = Configs.find_by_name('online_timeout')
    rec.update_attributes(:value => (visit_tm+1))
    rec.errors.on(:online_timeout).should_not be_blank
  end

  it 'should contain visit_timeout is greater than online_timeout' do
    online_tm = Configs.find_by_name('online_timeout').value.to_i
    rec = Configs.find_by_name('visit_timeout')
    rec.update_attributes(:value => (online_tm-1))
    rec.errors.on(:visit_timeout).should_not be_blank
  end

  it 'should contain online_timeout is less or equal to 99999' do
    rec = Configs.find_by_name('online_timeout')
    rec.update_attributes(:value => (99_999 + 1))
    rec.errors.on(:online_timeout).should_not be_blank
  end

  it 'should contain visit_timeout is less or equal to 99999' do
    rec = Configs.find_by_name('visit_timeout')
    rec.update_attributes(:value => (99_999 + 1))
    rec.errors.on(:visit_timeout).should_not be_blank
  end

  it 'should validate number values' do
    ['redirect_timeout', 'topperpage', 'postsperpage', 'topreview'].each do |name|
      rec = Configs.find_by_name(name)
      rec.update_attributes(:value => Faker.letterify('????'))
      rec.errors.on(name).should_not be_blank
      rec.update_attributes(:value => (99_999 + 1))
      rec.errors.on(name).should_not be_blank
    end
  end

  it 'should return icons for attachments' do
    icons_coll = []
    ext = Configs.get_config('attach_icon_ext').split(',')
    icons = Configs.get_config('attach_icon_name').split(',')
    [ext.size, icons.size].min.times do |t|
      icons_coll << [ext[t].strip, icons[t].strip]
    end
    Configs.get_icon_collection.should =~ icons_coll
  end

  it 'should remove db data for icon that does not exist' do
    icons_coll = Configs.get_icon_collection
    #create 'shadow' icon (exists only in db)
    rec = Configs.find_by_name('attach_icon_name')
    rec.update_attributes(:value => rec.value << ", #{Faker.letterify('????')}.#{MimeMagic::EXTENSIONS.keys.random_element}")
    Configs.get_not_avail_icons
    Configs.get_icon_collection.should =~ icons_coll
  end

  it 'should get icon file by extension' do
    random_ext = MimeMagic::EXTENSIONS.keys.random_element
    Configs.get_icon('.' + random_ext).nil?.should_not be_eql(Configs.get_config('attach_icon_ext').split(',').include?(random_ext))
  end
  
  describe 'is_allowed_ext method' do

    before(:all) do
      @file = Faker.letterify('?????') + '.' + MimeMagic::EXTENSIONS.keys.random_element
    end

    it 'should return nil' do
      Configs.is_allowed_ext('filename').should be_nil
    end

    it 'should return error' do
      unless @user.group.attach_disallowed_extensions.blank? || (@user.group.attach_disallowed_extensions.split(',') - Configs.get_config('attach_always_deny').to_s.split(',')).include?(file_ext.tr('.',''))
        Configs.is_allowed_ext(@file, @user.group).should be_kind_of(String)
      else
        if Configs.get_config('attach_always_deny').to_s.split(',').collect{|el| el='.' + el.strip}.include?(File.extname(@file))
          Configs.is_allowed_ext(@file, @user.group).should be_eql('Such type of file is not allowed to upload')
        end
      end
    end

  end

  it 'should check whether image with such extension is allowed to upload' do
    random_ext = MimeMagic::EXTENSIONS.keys.random_element
    Configs.is_allowed_img(Faker.letterify('?????')).should be_false
    Configs.is_allowed_img(Faker.letterify('?????') + '.' + random_ext).should be_eql(%w/git jpg jpeg png/.include?(random_ext))
  end

  it 'should check whether icon with such extension is allowed to upload' do
    random_ext = MimeMagic::EXTENSIONS.keys.random_element
    Configs.is_allowed_icon(Faker.letterify('?????')).should be_false
    Configs.is_allowed_icon(Faker.letterify('?????') + '.' + random_ext).should be_eql(%w/git jpg jpeg png ico/.include?(random_ext))
  end

  it 'should return config value by config name or nil' do
    random_record = Configs.all.random_element
    random_name = Faker.letterify('??????')
    Configs.get_config(random_record.name).should be_eql(random_record.value)
    Configs.get_config(random_name).nil?.should be_eql(Configs.find_by_name(random_name).nil?)
  end

  #add tests for attach configuration method here
  ##########
  describe 'save_attach_configuration method' do
    
    it 'should return nil for illegal parameter' do
      Configs.save_attach_configuration(nil).should be_nil
      Configs.save_attach_configuration(123456).should be_nil
      Configs.save_attach_configuration('123456').should be_nil
      Configs.save_attach_configuration({}).should be_nil
    end
    
    it 'should correct save attachment configuration data' do
      attach_params = ['attach_disable_attach', 'attach_allow_orphans', 'attach_always_deny', 'attach_disp_small', 'attach_small_height',
                                'attach_small_weight', 'attach_use_icon']
      Configs.save_attach_configuration({attach_params[0] => true})#.should be_eql(Configs.get_config(attach_params[0]).to_bool)
      debugger
      Configs.get_config(attach_params[0]).to_bool.should be_true
      Configs.save_attach_configuration({attach_params[1] => true})#.should be_eql(Configs.get_config(attach_params[1]).to_bool)
      Configs.get_config(attach_params[1]).to_bool.should be_true
      Configs.save_attach_configuration({attach_params[2] => true})#.should be_eql(Configs.get_config(attach_params[2]).to_bool)
      Configs.get_config(attach_params[2]).to_bool.should be_true
      Configs.save_attach_configuration({attach_params[3] => true})#.should be_eql(Configs.get_config(attach_params[3]).to_bool)
      Configs.get_config(attach_params[3]).to_bool.should be_true
      Configs.save_attach_configuration({attach_params[4] => '300'})#.should be_eql(Configs.get_config(attach_params[4]))
      Configs.get_config(attach_params[4]).should be_eql('300')
      Configs.save_attach_configuration({attach_params[5] => '300'})#.should be_eql(Configs.get_config(attach_params[5]))
      Configs.get_config(attach_params[5]).should be_eql('300')
      Configs.save_attach_configuration({attach_params[6] => true})
      Configs.get_config(attach_params[6]).to_bool.should be_true
    end
    
    it 'should return nil for empty list of icons or their extensions' do
      h = rand(2).to_bool ? {:icon => nil} : {:iconfile => nil}
      Configs.save_attach_configuration(rand(2).to_bool ? {:icon => nil} : {:iconfile => nil}).should be_nil           
    end
    
    it 'should return error if icon_ext array is less than icon_file array' do
      params = {:icon => {'0' => 'txt', '1' => 'doc'}, :iconfile => {'0' => 'txt.png', '1' => 'doc.png', '2' => 'doc.png'}}
      Configs.save_attach_configuration(params).should be_eql('There is no icon for appropriate file.')
    end
    
    it 'should return error if icon_ext array is greater than icon_file array' do
      params = {:icon => {'0' => 'txt', '1' => 'doc'}, :iconfile => {'0' => 'txt.png'}}
      Configs.save_attach_configuration(params).should be_eql('There is no file for appropriate icon.')
    end
    
    it 'should return error for trying to add icon with empty field(s)' do
      params = {:icon => {'0' => 'txt', '1' => 'doc'}, :iconfile => {'0' => 'txt.png', '1' => 'doc.png'}}
      params[:add_icon_type] = 'xls'
      params[:add_icon_file] = ''
    #  debugger
      Configs.save_attach_configuration(params).should be_nil#eql('There is no file for appropriate icon.')
      params[:add_icon_file] = 'xls.png'
      params[:add_icon_type] = ''
      Configs.save_attach_configuration(params).should be_nil#eql('There is no icon for appropriate file.')
    end
    
    it 'should return nil for newly created icon record' do
      params = {:icon => {'0' => 'txt', '1' => 'doc'}, :iconfile => {'0' => 'txt.png', '1' => 'doc.png'}, :add_icon_type => 'xls', :add_icon_file => 'xls.png'}
      Configs.save_attach_configuration(params).should be_nil
    end
    
  end

  it 'should return maximum allowed avatar size' do
    Configs.get_avatar_size.should be_eql((Configs.get_config('maxwidth_avatars').to_s) + 'x' + (Configs.get_config('maxheight_avatars').to_s))
  end

  it 'should return maximum allowed attachment image size' do
    Configs.get_attach_image_size.should be_eql((Configs.get_config('attach_small_height').to_s + 'x' + Configs.get_config('attach_small_weight').to_s))
  end

  it 'should check whether registration will be verified by e-mail' do
     Configs.verify_by_email.should be_eql(Configs.get_config('verify_registration').to_bool)
  end

  it 'should update notices attributes' do
    Configs.update_notices(nil, nil, nil)
    Configs.get_config('allow_notice').should be_nil
    Configs.get_config('notice_title').should be_nil
    Configs.get_config('notice_message').should be_nil
  end

end