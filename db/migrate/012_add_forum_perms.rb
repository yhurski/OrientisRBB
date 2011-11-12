class AddForumPerms < ActiveRecord::Migration
  def self.up
    create_table :forum_perms, :force => true do |t|
       t.column :group_id, :integer, :null => false
       t.column :subpartition_id, :integer, :null => false
       t.column :read_forum, :boolean, :null => false, :default => false
       t.column :post_replies, :boolean, :null => false, :default => false
       t.column :post_topics, :boolean, :null => false, :default => false
    end
  end

  def self.down                                                          
    drop_table :forum_perms
  end
end
