require 'factory_girl'
require 'ffaker'
require 'ruby-debug'

FactoryGirl.define do
  factory :rank do |r|
    r.id { Rank.maximum(:id).nil? ? 1 : Rank.maximum(:id) + 1}
    r.rank { Faker::Lorem.words(rand(2) + 1)  }
    r.num_of_posts {rand(10000)}
  end
  
  factory :partition do |p|
    p.id { Partition.maximum(:id).nil? ? 1 : Partition.maximum(:id) + 1  }
    p.title { Faker::Lorem.sentence }
    p.part_pos { Faker.numerify '#' * (rand(10) + 1) }
    p.subpartitions { FactoryGirl.create_list(:subpartition, rand(10)) }
  end  
  
  factory :subpartition do |s|
    s.id { Subpartition.maximum(:id).nil? ? 1 : Subpartition.maximum(:id) + 1  }
    s.partition_id {((Partition.find(:first, :offset => (Partition.count * rand).to_i) && Partition.find(:first, :offset => (Partition.count * rand).to_i).id) || 0)}
    s.title { Faker::Lorem.sentence }
    s.desc { Faker::Lorem.sentences(rand(5)).join(' ') }
    s.part_pos { Faker.numerify '#' * (rand(10) + 1) }
    s.last_post { (Subpartition.last_post(id) && Subpartition.last_post(id).last_post) || Time.now.utc}
    s.last_post_id  { (Subpartition.last_post(id) && Subpartition.last_post(id).last_post_id) || 0}
    s.last_poster  { (Subpartition.last_post(id) && Subpartition.last_post(id).last_poster) || Faker::Name.first_name}
    s.topics { FactoryGirl.create_list(:topic,  rand(10)) }
    after_build do |s|
      unless Topic.find(:all,  :conditions => ["subpartition_id = ?", s.id]).empty?
        Topic.find(:all,  :conditions=> ["subpartition_id = ?", s.id]).each {|t| s.num_posts += t.num_replies }
        s.num_topics = Topic.find(:all,  :conditions => ["subpartition_id = ?", s.id]).size
        s.save
      end
    end
  end

  factory :topic do |t|
    t.id { Topic.maximum(:id).nil? ? 1 : Topic.maximum(:id) + 1  }
    t.subpartition_id {((Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i) && Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i).id) || 1)}
    t.poster {((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).name) || 0)}
    t.first_post_id {(Post.find(:first, :offset => (Post.count * rand).to_i && Post.find(:first, :offset => (Post.count * rand).to_i).id) || 1)}
    t.title { Faker::Lorem.sentence }
    t.last_post { (Topic.last_post(id) && Topic.last_post(id).posted) || Time.now.utc }
    t.last_post_id { (Topic.last_post(id) && Topic.last_post(id).id) || 0  }
    t.last_poster { (Topic.last_post(id) && Topic.last_post(id).poster) || Faker::Name.first_name }
    t.num_views { rand(10000) }
    t.num_replies { (Post.find(:all, :conditions => ["topic_id = ?", id]) && Post.find(:all, :conditions => ["topic_id = ?", id]).size) || 1 }
    t.closed { rand 2 }
    t.sticky { rand 2 }
    t.moved_to { 0 }
    t.poster_id { User.find(poster).id unless poster.to_i == 0 }
    after_build do |t|
      if Subpartition.exists? t.subpartition_id
        Subpartition.find(t.subpartition_id).increment!(:num_topics)
        Subpartition.find(t.subpartition_id).increment!(:num_posts)
      end
    end
  end

  factory :post do |p|
    p.id { Post.maximum(:id).nil? ? 1 : Post.maximum(:id) + 1  }
    p.topic_id {(Topic.find(:first, :offset => (Topic.count * rand).to_i && Topic.find(:first, :offset => (Topic.count * rand).to_i).id) || 1)}
    p.poster_id {(User.find(:first, :offset => (User.count * rand).to_i && User.find(:first, :offset => (User.count * rand).to_i).id) || 1)}
    p.poster  {(User.find(poster_id) && User.find(poster_id).name) || ''}
    p.message { Faker::Lorem.sentences(rand(10)).join(' ') }
    p.posted { Time.now.utc  }
    p.edited { rand(20) == 10 ? Time.now.utc : nil  }
    p.edited_by { poster unless edited.nil? }
    p.poster_ip { Faker::Internet.ip_v4_address }
    after_build do |p|
      if User.exists? p.poster_id
        User.find(p.poster_id).increment!(:numposts)
      end
      if Topic.exists? p.topic_id
        Topic.find(p.topic_id).increment!(:num_replies)
        Topic.find(p.topic_id).increment!(:num_posts)
      end
    end
  end
  
  factory :user do |u|
    u.id { User.maximum(:id).nil? ? 1 : User.maximum(:id) + 1  }
    u.name { Faker::Name.first_name  }
    u.email { Faker::Internet.email }
    u.regdatetime { Time.now.utc - rand(1000).days - rand(1000).hours - rand(1000).minutes }
    u.plain_passwd { Faker::Name.last_name  }
    u.salt { Faker.letterify '?????'  }
    u.passwd { User.get_md5_passwd_hash(u.plain_passwd, u.salt) }
    u.last_post_datetime { Time.now.utc unless (rand(5) == 0)  }
    u.realname {  Faker::Name.name if (rand(2) == 0) }
    u.location { Faker::Address.city if (rand(2) == 0)  }
    u.web { Faker::Internet.uri('http') if (rand(2) == 0)  }
    u.signature { Faker::Lorem.sentences(rand(5) + 1) if rand(3) == 0 }
    u.jabber { Faker::Internet.email if rand(5) == 0  }
    u.icq { Faker.numerify('#####' + rand(5)) if rand(5) == 0 }
    u.msn { Faker.numerify('#####' + rand(10)) if rand(10) == 0 }
    u.aim { Faker.numerify('#####' + rand(10)) if rand(10) == 0 }
    u.yahoo { Faker::Internet.email if rand(10) == 0  }
    u.forum_style { (Configs && Configs.get_config('default_style')) || 'Default_blue' }
    u.smiles_to_img { rand(2) }
    u.show_users_sign { rand(2) }
    u.show_img_inmess { rand(2) }
    u.show_img_insign { rand(2) }
    u.themes_per_page { (Configs && Configs.get_config('topperpage')) || 30 }
    u.posts_per_page { (Configs && Configs.get_config('postsperpage')) || 20 }
    u.timezone { (Configs && Configs.get_config('default_timezone')) || 'UTC' }
    u.forum_lang { (Configs && Configs.get_config('default_lang')) || 'en' }
    u.howshowemail { (Configs && Configs.get_config('email_default')) || '2' }
    u.title { Faker::Lorem.words(rand(2) + 1) }
    u.group_id { (defined?(Group) && Group.all.map(&:id)[rand(Group.count)]) || 1 }
    u.registration_ip { Faker::Internet.ip_v4_address }
    u.date_format { (defined?(Configs) && Configs.get_config('default_timeformat')) || '%H:%M:%S' }
    u.time_format { (defined?(Configs) && Configs.get_config('default_dateformat')) || '%Y-%m-%d' }
    u.adminnote { Faker::Lorem.sentences(rand(2) + 1) if rand(7) == 0 }
    u.numposts { rand(1000)  }
    u.dst { (defined?(Configs) && Configs.get_config('dst')) || '0' }
    u.last_visit { Time.now.utc  }
    u.last_page ' '
    u.avatar_file_name ' '
    u.avatar_content_type ' '
    u.avatar_file_size 0
    u.avatar_updated_at { Time.now.utc }
  end
  
  factory :attach_file do |a|
    a.id { AttachFile.maximum(:id).nil? ? 1 : AttachFile.maximum(:id) + 1  }
    a.user_id {((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).id) || 0)}
    a.post_id {((Post.find(:first, :offset => (Post.count * rand).to_i) && Post.find(:first, :offset => (Post.count * rand).to_i).id) || 0)}
    a.topic_id {((Topic.find(:first, :offset => (Topic.count * rand).to_i) && Topic.find(:first, :offset => (Topic.count * rand).to_i).id) || 0)}
    a.attach_file_name ' '
    a.attach_file_size 0
    a.attach_content_type ' '
    a.download_counter 0
    a.attach_updated_at { Time.now.utc  }
  end
  
  factory :session do |s|
    s.id { Session.maximum(:id).nil? ? 1 : Session.maximum(:id) + 1  }
    s.session_id ' '
    s.data ' '
    s.created_at { Time.now.utc  }
    s.updated_at { Time.now.utc  }
  end
    
  factory :ban do |b|
    b.id { Ban.maximum(:id).nil? ? 1 : Ban.maximum(:id) + 1  }
    b.username {((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).name) || Faker::Name.first_name)}
    b.ip {  Faker::Internet.ip_v4_address }
    b.email { Faker::Internet.email  }
    b.message { Faker::Lorem.sentences(rand(10) + 1).join(' ') }
    b.expire { Time.now.utc + rand(1000).days + rand(1000).hours + rand(1000).minutes }
    b.ban_creator  {((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).id) || 0)}
  end
  
  factory :censors do |c|
    c.id { Creator.maximum(:id).nil? ? 1 : Creator.maximum(:id) + 1  }
    c.source_word { Faker::Lorem.word }
    c.dest_word { Faker::Lorem.word }
  end
  
  factory :forum_perm do |f|
    f.id { ForumPerm.maximum(:id).nil? ? 1 : ForumPerm.maximum(:id) + 1  }
    f.group_id { (defined?(Group) && Group.all.map(&:id)[rand(Group.count)]) || 1 }
    f.subpartition_id {((Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i) && Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i).id) || 0)}
    f.read_forum { rand(2) }
    f.post_replies { rand(2) }
    f.post_topics { rand(2) }
  end
  
  factory :report do |r|
    r.id { Report.maximum(:id).nil? ? 1 : Report.maximum(:id) + 1  }
    r.post_id {((Post.find(:first, :offset => (Post.count * rand).to_i) && Post.find(:first, :offset => (Post.count * rand).to_i).id) || 0)}
    r.topic_id {((Topic.find(:first, :offset => (Topic.count * rand).to_i) && Topic.find(:first, :offset => (Topic.count * rand).to_i).id) || 0)}
    r.subpartition_id {((Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i) && Subpartition.find(:first, :offset => (Subpartition.count * rand).to_i).id) || 0)}
    r.reported_by {((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).id) || 0)}
    r.created_at { Time.now.utc + rand(1000).days + rand(1000).hours + rand(1000).minutes  }
    r.message { Faker::Lorem.sentences(rand(10) + 1).join(' ') }
    r.readed_at { rand(2) == 0 ? Time.now.utc : nil }
    r.readed_by {(((User.find(:first, :offset => (User.count * rand).to_i) && User.find(:first, :offset => (User.count * rand).to_i).id) || 0)) unless r.readed_at.nil? }
  end
  
  sequence :entity_id do |n|
    n
  end
end



