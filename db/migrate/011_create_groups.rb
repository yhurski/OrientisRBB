class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :force => true do |t|
       t.column :name, :string, :limit => 50, :null => false
       t.column :title_name, :string, :limit => 50
       t.column :g_moderator, :boolean, :default => 0
       t.column :g_mod_edit_users, :boolean, :default => 0
       t.column :g_mod_rename_users, :boolean, :default => 0
       t.column :g_mod_change_password, :boolean, :default => 0
       t.column :g_mod_ban_users, :boolean, :default => 0
       t.column :g_read_board, :boolean, :default => 1
       t.column :g_view_users, :boolean, :default => 1
       t.column :g_post_replies, :boolean, :default => 1
       t.column :g_post_topics, :boolean, :default => 1
       t.column :g_edit_posts, :boolean, :default => 1
       t.column :g_delete_posts, :boolean, :default => 1
       t.column :g_delete_topics, :boolean, :default => 1
       t.column :g_set_title, :boolean, :default => 1
       t.column :g_search, :boolean, :default => 1
       t.column :g_search_users, :boolean, :default => 1
       t.column :g_send_email, :boolean, :default => 1
       t.column :g_post_flood, :smallint, :limit => 6, :null => false, :default => 30
       t.column :g_search_flood, :smallint, :limit => 6, :null => false, :default => 30
       t.column :g_email_flood, :smallint, :limit => 6,:null => false, :default => 60
    end
  end

  def self.down
    drop_table :groups
  end

end
