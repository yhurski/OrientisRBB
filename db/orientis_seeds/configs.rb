      Configs.new(:name => 'board_title', :value => 'OrientisRBB').save
      Configs.new(:name => 'board_version', :value => '0.0.1 prealpha').save
      Configs.new(:name => 'board_desc', :value => 'Orientis is a Ruby On Rails board').save
      Configs.new(:name => 'default_style', :value => 'Default_blue').save
      Configs.new(:name => 'default_lang', :value => 'en').save
      Configs.new(:name => 'default_timezone', :value => 'UTC').save
      Configs.new(:name => 'dst', :value => 0).save
      Configs.new(:name => 'default_timeformat', :value => '%H:%M:%S').save
      Configs.new(:name => 'default_dateformat', :value => '%Y-%m-%d').save
      Configs.new(:name => 'visit_timeout', :value => '60').save
      Configs.new(:name => 'online_timeout', :value => '30').save
      Configs.new(:name => 'redirect_timeout', :value => '1').save
      Configs.new(:name => 'topperpage', :value => '30').save
      Configs.new(:name => 'postsperpage', :value => '20').save
      Configs.new(:name => 'topreview', :value => '15').save
      Configs.new(:name => 'rec_meth', :value => 1).save
      #features action
      Configs.new(:name => 'allow_search', :value => true).save
      Configs.new(:name => 'allow_rank', :value => true).save
      Configs.new(:name => 'allow_cens', :value => false).save
      Configs.new(:name => 'allow_jumpmenu', :value => true).save
      Configs.new(:name => 'show_version', :value => false).save
      Configs.new(:name => 'show_usersonline', :value => false).save
      Configs.new(:name => 'show_quickpost', :value => true).save
      Configs.new(:name => 'allow_topicssubsc', :value => true).save
      Configs.new(:name => 'allow_guestpost', :value => true).save
      Configs.new(:name => 'allow_usersdot', :value => false).save
      Configs.new(:name => 'show_views', :value => true).save
      Configs.new(:name => 'allow_postcount', :value => true).save
      Configs.new(:name => 'show_userinfo', :value => true).save
      Configs.new(:name => 'allow_bbc', :value => true).save
      Configs.new(:name => 'allow_bbc_img', :value => true).save
      Configs.new(:name => 'show_graphsmiles', :value => true).save
      Configs.new(:name => 'allow_bbcurl', :value => true).save
      Configs.new(:name => 'allow_capitals', :value => true).save
      Configs.new(:name => 'allow_capitalssubj', :value => true).save
      Configs.new(:name => 'allow_signature', :value => true).save
      Configs.new(:name => 'allow_bbcsignature', :value => true).save
      Configs.new(:name => 'allow_bbcimgsignature', :value => false).save
      Configs.new(:name => 'convert_smilestoicon', :value => true).save
      Configs.new(:name => 'allow_capitalssign', :value => true).save
      Configs.new(:name => 'allow_avatars', :value => true).save
      Configs.new(:name => 'quote_depth', :value => 3).save
      Configs.new(:name => 'maxchar_signature', :value => 400).save
      Configs.new(:name => 'maxlines_signature', :value => 4).save
      Configs.new(:name => 'dir_avatars', :value => '/public/img/avatars').save
      Configs.new(:name => 'maxwidth_avatars', :value => 60).save
      Configs.new(:name => 'maxheight_avatars', :value => 60).save
      Configs.new(:name => 'maxsize_avatars', :value => 10240).save
      #notices action
      Configs.new(:name => 'allow_notice', :value => false).save
      Configs.new(:name => 'notice_title', :value => 'Simple notice').save
      Configs.new(:name => 'notice_message', :value => 'simple notice message').save
      #email action
      Configs.new(:name => 'admin_email', :value => '').save
      Configs.new(:name => 'webmaster_email', :value => '').save
      Configs.new(:name => 'mailing_list', :value => '').save
      Configs.new(:name => 'smtp_address', :value => '').save
      Configs.new(:name => 'smtp_username', :value => '').save
      Configs.new(:name => 'smtp_password', :value => '').save
      Configs.new(:name => 'smtp_ssl', :value => 0).save
      #registration
      Configs.new(:name => 'allow_registration', :value => true).save
      Configs.new(:name => 'verify_registration', :value => false).save
      Configs.new(:name => 'email_registration', :value => false).save
      Configs.new(:name => 'email_registration_dub', :value => false).save
      Configs.new(:name => 'email_notify', :value => false).save
      Configs.new(:name => 'use_rules', :value => false).save
      Configs.new(:name => 'email_default', :value => 1).save
      Configs.new(:name => 'rules_text', :value => '').save
      #attachment
      Configs.create(:name => 'attach_always_deny', :value => 'html,htm,js,rb,erb,rhtml,exe,com,cmd,bat')
      Configs.create(:name =>  'attach_allow_orphans', :value => 1)
      Configs.create(:name => 'attach_icon_folder', :value => '/icons')
      Configs.create(:name => 'attach_icon_ext', :value => 'txt,doc,pdf')
      Configs.create(:name => 'attach_icon_name', :value => 'text.png,doc.png, doc.png')
      Configs.create(:name => 'attach_subfolder', :value => Digest::MD5.hexdigest(DateTime.now.to_s))
      Configs.create(:name => 'attach_use_icon', :value => 1)
      Configs.create(:name => 'attach_disp_small', :value => 1)
      Configs.create(:name => 'attach_small_height', :value => 100)
      Configs.create(:name => 'attach_small_weight', :value => 100)
      Configs.create(:name => 'attach_disable_attach', :value => 0)
      #new
      Configs.new(:name => 'default_group', :value => 4).save
      Configs.new(:name => 'enable_maintenance', :value => 0).save
      Configs.new(:name => 'maintenance_text', :value => '').save
