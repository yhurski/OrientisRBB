class Configs < ActiveRecord::Base
  set_table_name :configs
  
  NUMBER_REGEXP = /^[0-9]+$/
  REGISTRATION_FLOOD_TIMEOUT = 60 * 60				#seconds
  
  validates_each :name do |record, attr_name, value|
    if value == 'visit_timeout'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:vt_be_a_number))
      end
      unless Configs.find_by_name('online_timeout').nil?                                                                                          #if we are loading a config's seed, record with 'online_timeout may be not exists'
        # <= changed
        if record.value.to_i <= Configs.find_by_name('online_timeout').value.to_i
          record.errors.add(value, I18n.t(:vt_be_greater))
        end
      end
      if record.value.to_i > 99999
        record.errors.add(value, I18n.t(:vt_be_less))
      end
    end
      
    if value == 'online_timeout'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:ot_be_a_number))
      end
      unless Configs.find_by_name('visit_timeout').nil?                                                                                          #if we are loading a config's seed, record with 'visit_timeout may be not exists'
        #>= changed
        if record.value.to_i >= Configs.find_by_name('visit_timeout').value.to_i
          record.errors.add(value, I18n.t(:ot_be_less_vt))
        end
      end
      if record.value.to_i > 99999
        record.errors.add(value, I18n.t(:ot_be_less))
      end
    end
      
    if value == 'redirect_timeout'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:rt_be_a_number))
      end
      if record.value.to_i > 99999
        record.errors.add(value, I18n.t(:rt_be_less))
      end
    end
      
    if value == 'topperpage'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:topperpage_be_a_number))
      end
      if record.value.to_i > 999
        record.errors.add(value, I18n.t(:topperpage_be_less))
      end
    end
      
    if value == 'postsperpage'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:postsperpage_be_a_number))
      end
      if record.value.to_i > 999
        record.errors.add(value, I18n.t(:postsperpage_be_less))
      end
    end
      
    if value == 'topreview'
      unless record.value =~ NUMBER_REGEXP
        record.errors.add(value, I18n.t(:topreview_be_a_number))
      end
      if record.value.to_i > 999
        record.errors.add(value, I18n.t(:topreview_be_less))
      end
    end
  end
  
  def self.get_icon_collection
    res = []
    ext = get_config('attach_icon_ext').split(',')
    icons = get_config('attach_icon_name').split(',')
    [ext.size, icons.size].min.times do |t|
      res << [ext[t].strip, icons[t].strip]
    end
    res
  end
  
  def self.get_not_avail_icons
    relative_path = File.join('public', Configs.get_config('attach_icon_folder'))
    get_config('attach_icon_name').split(',').reject  do |icon_name|
      FileTest.exist? File.join(RAILS_ROOT, relative_path, icon_name.strip)
    end
  end
      
  def self.get_icon ext
    all_ext = get_config('attach_icon_ext').split(',')
    all_icons = get_config('attach_icon_name').split(',')
    [all_ext.size, all_icons.size].min.times do |t|
      return all_icons[t].strip if ('.' + all_ext[t].strip) == ext
    end
    nil
  end
      
  def self.is_allowed_ext filename, group=nil
    file_ext = File.extname(filename).downcase
    return nil if file_ext.blank?
    if group && ! group.attach_disallowed_extensions.blank?#nil?
      return (I18n.t(:upload_allowed) + file_ext + I18n.t(:files)) unless (group.attach_disallowed_extensions.split(',') - Configs.get_config('attach_always_deny').to_s.split(',')).include?(file_ext.tr('.',''))
    end
    Configs.get_config('attach_always_deny').to_s.split(',').each do |forb_ext|
      return I18n.t(:not_allowed) if ('.' + forb_ext) == file_ext
    end
    nil
  end
      
  def self.is_allowed_img filename
    file_ext = File.extname(filename).downcase
    return false if file_ext.blank?
    return true if file_ext =~ /^\.(gif|jpg|jpeg|png)$/
    false
  end
      
  #TODO: refactoring
  def self.is_allowed_icon iconname
    icon_ext = File.extname(iconname).downcase
    return false if icon_ext.blank?
    return true if icon_ext =~ /^\.(gif|jpg|jpeg|png|ico)$/
    false
  end
    
  def self.get_config(name)
    config_unit = Configs.find_by_name(name)
    unless config_unit.nil?
      return config_unit.value
    end
    return nil
  end
 
  #OPTIMIZE: all
  def self.save_attach_configuration(params={})
    return nil if params.blank? || ! params.kind_of?(Hash)
    Configs.find_by_name('attach_disable_attach').update_attributes(:value => params[:attach_disable_attach])
    Configs.find_by_name('attach_allow_orphans').update_attributes(:value => params[:attach_allow_orphans])
    Configs.find_by_name('attach_always_deny').update_attributes(:value => params[:attach_always_deny])
    Configs.find_by_name('attach_disp_small').update_attributes(:value => params[:attach_disp_small])
    Configs.find_by_name('attach_small_height').update_attributes(:value => params[:attach_small_height])
    Configs.find_by_name('attach_small_weight').update_attributes(:value => params[:attach_small_weight])
    Configs.find_by_name('attach_use_icon').update_attributes(:value => params[:attach_use_icon])
    no_icon_message = "There is no icon for appropriate file."
    no_file_message = "There is no file for appropriate icon."
    add_new_icon_record_notice = nil
        
    return nil if params[:icon].nil? || params[:iconfile].nil?
    return no_icon_message if params[:icon].values.reject{|v| v.blank?}.size < params[:iconfile].values.reject{|v| v.blank?}.size
    return no_file_message if params[:icon].values.reject{|v| v.blank?}.size > params[:iconfile].values.reject{|v| v.blank?}.size
    icon_exts = Configs.find_by_name('attach_icon_ext')
    if  params[:add_icon_type].strip.size > 0 && params[:add_icon_file].strip.size == 0
      icon_exts.value = params[:icon].values.reject{|v| v.blank?}.map{|v| v.strip}.join(',')
      add_new_icon_record_notice = no_file_message
    else
      icon_exts.value = params[:icon].values.reject{|v| v.blank?}.map{|v| v.strip}.push(params[:add_icon_type]).join(',')
    end
    icon_exts.save
    icon_name = Configs.find_by_name('attach_icon_name')
    if params[:add_icon_file].strip.size > 0 && params[:add_icon_type].strip.size == 0
      icon_name.value = params[:iconfile].values.reject{|v| v.blank?}.map{|v| v.strip}.join(',')
      add_new_icon_record_notice = no_icon_message
    else
      icon_name.value = params[:iconfile].values.reject{|v| v.blank?}.map{|v| v.strip}.push(params[:add_icon_file]).join(',')
    end
    icon_name.save
    return add_new_icon_record_notice
  end
 
  def self.get_avatar_size
    (Configs.get_config('maxwidth_avatars').to_s) + 'x' + (Configs.get_config('maxheight_avatars').to_s)
  end

  def self.get_attach_image_size
    "#{Configs.get_config('attach_small_height') || 100}x#{Configs.get_config('attach_small_weight')}"
  end
  
  def self.verify_by_email
    get_config('verify_registration').to_i > 0 ? true : false
  end
  
  def self.update_notices(allow_notice, notice_title, notice_message)
    find_by_name('allow_notice').update_attribute(:value, allow_notice)
    find_by_name('notice_title').update_attribute(:value, notice_title)
    find_by_name('notice_message').update_attribute(:value, notice_message)
  end
end