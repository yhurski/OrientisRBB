Post.create(:topic_id => Topic.first,
  :poster => User.first.name,
  :poster_id => User.first.id,
  :message => 'Test message',
  :posted => Time.now.utc,
  :edited => 0,
  :edited_by => 0,
  :poster_ip => User.first.registration_ip )

Subpartition.first.update_attributes(:last_post => Post.last.posted, :last_post_id => Post.last.id, :last_poster => Post.last.poster)