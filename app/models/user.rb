class User < ActiveRecord::Base
  has_many :posts, :foreign_key => 'poster_id'
  has_many :topics, :foreign_key => 'poster_id'
  has_many :bans, :foreign_key => 'ban_creator'
  has_many :attach_files
  belongs_to :group
  has_many :reports, :foreign_key => 'user_id'
  has_many :bans, :foreign_key => 'ban_creator'
  has_and_belongs_to_many :subpartitions
  before_create :crypt_password
  before_validation :nullify_attr
  has_attached_file :avatar, :styles => {:thumb => Configs.get_avatar_size},:convert_options => {:all => '-strip'}

  validates_presence_of :name
  validates_length_of :name, :in => 3..25
  validates_format_of :name, :with => /^\w{3,25}$/i
  validates_uniqueness_of :name
  validates_presence_of :passwd, :if => :isvalidate
  validates_length_of :passwd, :in => 5..32, :if => :isvalidate
  validates_email_format_of :email, :if => :isvalidate
  validates_email_format_of :new_email, :if => :isvalidate
  validates_length_of :new_email, :in => 8..70, :if => :isvalidate
  validates_length_of :email, :in => 8..70
  validates_format_of :web, :with => /^http[s]?:\/\/.+$/i, :allow_nil => true, :allow_blank => true
  validates_attachment_size :avatar, :less_than => (Configs.get_config('maxsize_avatars') || 15000).to_i


  validates_confirmation_of :email, :if => [:verify_by_email, :isvalidate]
  validates_confirmation_of :passwd, :unless => :verify_by_email, :if => :isvalidate
  validates_confirmation_of :passwd, :on => :update, :if => :isvalidate
  validates_confirmation_of :email, :on => :update, :if => :isvalidate

  validates_inclusion_of :howshowemail, :in => '0'..'2'
  validates_inclusion_of :dst, :in => [true, false, nil]
  validates_length_of :timezone, :in => 3..80

  validates_length_of :jabber, :maximum => 50, :allow_nil => true
  validates_numericality_of :icq, :allow_nil => true, :allow_blank => true
  validates_length_of :icq, :in => 4..15, :allow_nil => true, :allow_blank => true
  validates_length_of :msn, :maximum => 50, :allow_nil => true
  validates_length_of :aim, :maximum => 50, :allow_nil => true
  validates_length_of :yahoo, :maximum => 30, :allow_nil => true

  validates_length_of :realname, :maximum => 100, :allow_nil => true
  validates_length_of :location, :maximum => 100, :allow_nil => true
  validates_length_of :web, :maximum => 255, :allow_nil => true

  validate :signature_line_count
  validates_length_of :signature, :maximum => Configs.get_config('maxchar_signature').to_i, :allow_nil => true

  validates_numericality_of :themes_per_page
  validates_numericality_of :posts_per_page
  validates_length_of :themes_per_page, :maximum => 4, :allow_nil => true
  validates_length_of :posts_per_page, :maximum => 4, :allow_nil => true

  validates_presence_of :last_visit
  validates_length_of :title, :maximum => 50, :allow_nil => true, :allow_blank => true, :message => 'Title field is too long'
	
  validates_each :registration_ip, :on => :create do |record, name, value|
    users_same_ip = User.find(:all, :conditions => ['registration_ip = ?', value], :order => 'regdatetime asc')
    if ! users_same_ip.empty? && (DateTime.now.utc  < (users_same_ip.last.regdatetime + Configs::REGISTRATION_FLOOD_TIMEOUT.seconds))
      record.errors.add(name, I18n.t(:double_ip))
    end
  end
          
  validates_each :email, :unless => :regist_with_banned_email  do |record, name, value|
    if record.id.nil?
      if Ban.exists?(["email = ?", value])
        record.errors.add(name, I18n.t(:banned_email))
      end
    else
      if Ban.exists?(["email = ? and username <> ?", value, record.name])
        record.errors.add(name, I18n.t(:banned_email))
      end
    end
  end
          
  validates_each :email, :unless => :regist_with_dub_email do |record, name, value|
    if record.id.nil?
      if User.exists?(["email = ?", value])
        record.errors.add(name, I18n.t(:double_email))
      end
    else
      if User.exists?(["email = ? and id <> ?", value, record.id])
        record.errors.add(name, I18n.t(:double_email))
      end
    end
  end

  #crypt password field on update record hook
  validates_each :passwd, :on => :update do |record, name, value|
    unless record.id.nil?
      if exists?(record.id) && find(record.id).passwd != value && record.changed.include?(name.to_s)
        record.passwd = get_md5_passwd_hash(value, record.salt)
      end
    end
  end

  named_scope :order_by_asc, lambda{|field| {:order => "#{field} ASC"}}
  named_scope :order_by_desc, lambda{|field| {:order => "#{field} DESC"}}
  named_scope :all_from_group, lambda{|group_id| {:conditions => ["group_id = ?", group_id]}}

  def plain_password
    @plain_password
  end

  def plain_password=(passwd)
    @plain_password = passwd
  end

  def new_email
    @new_email
  end

  def new_email=(email)
    @new_email = email
  end

  def isvalidate
    if @isvalidate.nil?
      true
    else
      @isvalidate
    end
  end

  def isvalidate=(validate)
    @isvalidate = validate
  end

  def admin?
    self.group.admin?
  end

  def logined? session
    if session.kind_of?(Hash) && session.has_key?(:user_id)
      session[:user_id] ? true : false
    else
      false
    end
  end

  def self.logout!(session, cookies)
    session[:user_id] = nil                                         #user's database id
    session[:save_session] = nil                              
    cookies.delete(:orientisrbb_session)
    cookies.delete(:stay_with_me_orientis)
  end

  def get_user_status
    if self.group.g_set_title
      status_message = self.title || self.group.title_name
    else
      status_message = self.group.title_name
    end
    if Configs.get_config('allow_rank').to_bool
      unless (according_ranks = Rank.find(:all, :conditions => ["num_of_posts <= ?", self.numposts])).blank?
        status_message = according_ranks.sort{|r1, r2| r2.num_of_posts <=> r1.num_of_posts}.first.rank
      end
    end
    status_message
  end

  def online?
    if Online.user_exists? self
      return Online.find_by_user_object(self).last_visit + Configs.get_config('online_timeout').to_i.seconds >= Time.now.utc
    end
    false
  end

  def get_online_status
    online? ? 'Online'  : 'Offline'  
  end

  def is_website_defined
    web.blank? ? false : true  
  end

  def is_location_defined
    location.blank? ? false : true  
  end

  def save_avatar user_avatar_hash
    if user_avatar_hash.kind_of?(Hash) && user_avatar_hash.has_key?(:avatar)
      self.isvalidate = false
      self.update_attributes(:avatar => user_avatar_hash[:avatar])
      self.isvalidate = true
      true
    else
      false
    end
  end

  #TODO: remove me
  def is_attachment_allowed
    self.group.attach_allow_upload#.to_i > 0 ? true : false
  end

  #TODO: remove me
  def max_attach_files_count
    self.group.attach_files_per_post
  end

  def self.create_registration_data(parameters, remote_addr='127.0.0.1')
    parameters[:users].update( { :salt => Password.random(4), :group_id => Configs.get_config('default_group'), :forum_style => Configs.get_config('default_style'),
        :forum_lang => (Configs.get_config('default_lang') || 'en'), :regdatetime => Time.now.utc, :last_visit => Time.now.utc,
        :themes_per_page => Configs.get_config('topperpage'), :posts_per_page => Configs.get_config('postsperpage'),
        :timezone => 'UTC', :dst => Configs.get_config('dst').to_bool, :registration_ip => remote_addr, :date_format => Configs.get_config('default_timeformat'),
        :time_format => Configs.get_config('default_dateformat'), :new_email => parameters[:users][:email]
      } )
    parameters[:users][:howshowemail] ||= Configs.get_config('email_default')
    if Configs.verify_by_email
      parameters[:users][:passwd] = Password.pronounceable
    end
    User.create(parameters[:users])
  end


  def proper_password? plain_password
    User.get_md5_passwd_hash(plain_password, self.salt) == self.passwd
  end

  def timedate_convert(time_with_zone)
    return nil unless time_with_zone.kind_of? Time
    time = time_with_zone.in_time_zone(self.timezone)
    unless self.dst
      time = time.isdst ? time - 1.hour : time
    end
    time.strftime(self.date_format + " " + self.time_format)
  end

  def user_date_to_utc time_date_str
    return nil if Time.zone.parse(time_date_str).nil?
    utc_time_date = Time.zone.parse(time_date_str) - Time.zone.now.in_time_zone(self.timezone).utc_offset
    if Time.zone.now.in_time_zone(self.timezone).isdst
      unless self.dst
        utc_time_date = utc_time_date + 1.hour
      end
    end
    utc_time_date
  end

  def pagination_posts_amount
    if self.posts_per_page.nil? || self.posts_per_page <= 0
      Configs.get_config('postsperpage')
    else
      self.posts_per_page
    end
  end

  def pagination_topics_amount
    if self.themes_per_page.nil? || self.themes_per_page <= 0
      Configs.get_config('topperpage')
    else
      self.themes_per_page
    end
  end

  def self.get_last_registered
    self.find(:all, :conditions => ['group_id <> ?', Group.get_guest.id]).sort{|f,s| f.regdatetime <=> s.regdatetime}.last
  end

  def is_moderator
    self.group.g_moderator
  end

  def allow_moderation?
    self.is_moderator && self.group.g_mod_edit_users
  end

  def numposts_inc
    self.increment!(:numposts)
  end

  def set_last_post
    self.update_attribute(:last_post, Time.now.utc)
  end

  def is_smiles_to_img
    Configs.get_config('show_graphsmiles').to_bool ? self.smiles_to_img : false
  end

  def is_show_signature
    Configs.get_config('allow_signature').to_bool ? self.show_users_sign : false
  end
  
  def self.get_guest
    User.find_by_group_id(Group.get_guest.id)
  end
  
  def clear_avatar
    self.isvalidate = false
    update_attributes(:avatar_file_name => nil, :avatar_content_type => nil, :avatar_file_size => nil, :avatar_updated_at => nil)
    self.isvalidate = true
  end

  def self.get_md5_passwd_hash plain_passwd, salt
    Digest::MD5.hexdigest(Digest::MD5.hexdigest(plain_passwd)+Digest::MD5.hexdigest(salt))
  end
  
  def self.get_user_list params
    return nil unless params.kind_of?(Hash) && params.has_key?(:users)
    name = params[:users][:name].gsub('*', '%')
    name = '%' if params[:users][:name].blank?
    if params[:users][:group] != '0'
      if params[:users][:order] == 'asc'
        User.all_from_group(params[:users][:group]).order_by_asc(params[:users][:sorting]).find(:all, :conditions => ["name like ? and group_id <> ?", name, User.get_guest.group.id])
      else                                                                                              #desc
        User.all_from_group(params[:users][:group]).order_by_desc(params[:users][:sorting]).find(:all, :conditions => ["name like ? and group_id <> ?", name, User.get_guest.group.id])
      end
    else
      if params[:users][:order] == 'asc'
        User.order_by_asc(params[:users][:sorting]).find(:all, :conditions => ["name like ? and group_id <> ?", name, User.get_guest.group.id])
      else
        User.order_by_desc(params[:users][:sorting]).find(:all, :conditions => ["name like ? and group_id <> ?", name, User.get_guest.group.id])
      end
    end
  end

private

  def verify_by_email
    Configs.verify_by_email
  end

  def dub_email_allowed?
    Configs.get_config('email_registration_dub').to_bool
  end

  def crypt_password
    self.plain_password = self.passwd
    self.passwd = User.get_md5_passwd_hash self.passwd, self.salt
    true
  end

  def nullify_attr
    self.jabber = nil if self.jabber.blank?
    self.icq = nil if self.icq.blank?
    self.msn = nil if self.msn.blank?
    self.aim = nil if self.aim.blank?
    self.yahoo = nil if self.yahoo.blank?

    self.realname = nil if self.realname.blank?
    self.location = nil if self.location.blank?
    self.web = nil if self.web.blank?

    self.signature = nil if self.signature.blank?

    self.themes_per_page = nil if self.themes_per_page.blank?
    self.posts_per_page = nil if self.posts_per_page.blank?
  end

  #TODO: lc - 1
  def signature_line_count
    allowed_line_count = Configs.get_config('maxlines_signature').to_i
    if self.signature.to_s.lc > allowed_line_count
      self.errors.add('signature', I18n.t(:signature_contain) + allowed_line_count.to_s + I18n.t(:lines))
    end
  end

  #TODO: refactor it
  def self.perform_full_search params, search_usr#=nil
    return nil unless params && params.kind_of?(Hash) && ! params.blank?
    params_arr = {:name => 25, :title => 50,:realname => 100, :location => 100,:signature => 65535, :adminnote => 255, :email => 70, :web => 255,
      :jabber => 50, :icq => 15, :msn => 50, :aim => 30, :yahoo => 30}
    search_conditions = ""
    search_params = []
    error_hash = {}
    int_size = 11
    params_arr.keys.each do |val|
      unless params[("search_"+val.to_s)].blank?
        if params[("search_"+val.to_s)].size > params_arr[val]
          error_hash[val] = "#{val.to_s.capitalize}" + I18n.t(:too_long)
          return error_hash
        end
        search_params << params[("search_"+val.to_s)].tr_s("*", "%")        #* (% - for mysql sql wildcard) - matchs any symbol or sequence of symbols
        search_conditions << "#{val.to_s} like ? "
        search_conditions << "and "
      end
    end
	
    unless params[:search_moreposts].blank?
      if params[:search_moreposts].size > int_size || (params[:search_moreposts] =~ Configs::NUMBER_REGEXP).nil?
        error_hash[:search_moreposts] = I18n.t(:more_posts_format)
        return error_hash
      end
      search_conditions << "numposts > #{params['search_moreposts']} "               #make sanitizening here
      search_conditions << " and "
    end
        
    unless params[:search_lessposts].blank?
      if params[:search_lessposts].size > int_size || (params[:search_lessposts] =~ Configs::NUMBER_REGEXP).nil?
        error_hash[:search_lessposts] = I18n.t(:less_posts_format)
        return error_hash
      end
      search_conditions << "numposts < #{params['search_lessposts']}"
      search_conditions << " and "
    end
        
    unless params[:search_postafter].blank?
      if Time.zone.parse(params[:search_postafter]).nil?
        error_hash[:search_postafter] = I18n.t(:last_post_after)
        return error_hash
      end
      search_conditions << "last_post_datetime > '#{search_usr.user_date_to_utc(params['search_postafter']).to_s(:db)}'"
      search_conditions << " and "
    end
        
    unless params[:search_postbefore].blank?
      if Time.zone.parse(params[:search_postbefore]).nil?
        error_hash[:search_postbefore] = I18n.t(:last_post_before)
        return error_hash
      end
      search_conditions << "last_post_datetime < '#{search_usr.user_date_to_utc(params['search_postbefore']).to_s(:db)}'"
      search_conditions << " and "
    end
        
    unless params[:search_regafter].blank?
      if Time.zone.parse(params[:search_regafter]).nil?
        error_hash[:search_regafter] = I18n.t(:regist_after)
        return error_hash
      end
      search_conditions << "regatetime < '#{search_usr.user_date_to_utc(params['search_regafter']).to_s(:db)}'"
      search_conditions << " and "
    end
        
    unless params[:search_regbefore].blank?
      if Time.zone.parse(params[:search_regbefore]).nil?
        error_hash[:search_regbefore] = I18n.t(:regist_before)
        return error_hash
      end
      search_conditions << "regdatetime < '#{search_usr.user_date_to_utc(params['search_regbefore']).to_s(:db)}'"
      search_conditions << " and "
    end
    search_conditions << "group_id <> #{Group.get_guest.id}" unless search_conditions.empty?
    if search_conditions.blank?
      nil
    else
      params[:s_orderby] = 'name' if params[:s_orderby].blank?
      params[:s_ordersort] = 'asc' if params[:s_ordersort].blank?
      params[:s_usergroup] = 0 if params[:s_usergroup].blank?
      if params[:s_usergroup].to_i == 0
        result_cond = [search_conditions, search_params].flatten
        User.find(:all, :conditions => result_cond, :order => "#{params[:s_orderby]} #{params[:s_ordersort]}")
      elsif params[:s_usergroup].to_i == -1
        search_conditions << ' and last_visit is null'
        result_cond = [search_conditions, search_params].flatten
        User.find(:all, :conditions => result_cond, :order => "#{params[:s_orderby]} #{params[:s_ordersort]}") 
      elsif Group.exists? params[:s_usergroup]
        search_conditions << ' and group_id = ?'
        search_params << params[:s_usergroup]
        result_cond = [search_conditions, search_params].flatten
        User.find(:all, :conditions => result_cond, :order => "#{params[:s_orderby]} #{params[:s_ordersort]}")
      else
        nil
      end
    end
  end

  #TODO: see user_date_to_utc
  def str_to_utc datetime_string
    Time.zone = self.timezone
    tz_time = Time.zone.parse(datetime_string)
    if tz_time.nil?
      Time.zone = 'UTC'
      return nil
    end
    unless self.dst
      tz_time = tz_time.isdst ? tz_time - 1.hour : tz_time
    end
    users_utc_time = tz_time.in_time_zone('utc')
    Time.zone = 'UTC'
    users_utc_time
  end
  
  def regist_with_banned_email
    isvalidate ? Configs.get_config('email_registration').to_bool : true
  end
  
  def regist_with_dub_email
    isvalidate ? Configs.get_config('email_registration_dub').to_bool : true
  end
end


