User.create(:name => 'admin',
            :email => 'admin@mail.com',
            :passwd => 'admin',
            :regdatetime => DateTime.now.utc,
            :salt => Password.random(4),
            :group_id => Group.get_admin.id,
            :registration_ip => '127.0.0.1',
            :numposts => 1,
            :dst => 0,
            :new_email => 'admin@mail.com',
            :howshowemail => Configs.get_config('email_default'),
            :timezone => 'UTC',
            :themes_per_page => Configs.get_config('topperpage'),
            :posts_per_page => Configs.get_config('postsperpage'),
            :last_visit => Time.now.utc,
            :forum_style => 'Acid_doom',
            :forum_lang => Configs.get_config('default_lang') || 'en',
            :date_format => Configs.get_config('default_timeformat'),
            :time_format => Configs.get_config('default_dateformat'),
            :last_post => Time.now.utc)

User.create(:name => 'guest',
            :email => 'guest@guest.com',
            :passwd => 'guest',
            :regdatetime => DateTime.now.utc,
            :salt => Password.random(4),
            :group_id => Group.get_guest.id,
            :registration_ip => '0.0.0.0',
            :numposts => 0,
            :dst => 0,
            :plain_password => 'guest',
            :new_email => 'guest@guest.com',
            :howshowemail => Configs.get_config('email_default'),
            :timezone => 'UTC',
            :themes_per_page => Configs.get_config('topperpage'),
            :posts_per_page => Configs.get_config('postsperpage'),
            :last_visit => Time.now.utc,
            :forum_style => Configs.get_config('default_style'),
            :forum_lang => Configs.get_config('default_lang') || 'en',
            :date_format => Configs.get_config('default_timeformat'),
            :time_format => Configs.get_config('default_dateformat'))

User.find_by_group_id(Group.get_guest.id).update_attribute(:passwd, 'guest')            
            