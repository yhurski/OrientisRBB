class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics, :force => true do |t|
      t.column :subpartition_id, :integer, :null => false           #FK
      t.column :poster, :string, :limit => 25, :null => false
      t.column :title, :string, :limit => 255, :null => false
      t.column :first_post_id, :integer, :null => false             #FK
      t.column :last_post, :datetime, :null => false
      t.column :last_post_id, :integer, :null => false              #FK
      t.column :last_poster, :string, :limit => 25, :null => false
      t.column :num_views, :integer, :limit => 10, :null => false
      t.column :num_replies, :integer, :limit => 10, :null => false
      t.column :closed, :boolean, :null => false, :default => false
      t.column :sticky, :boolean, :null => false, :default => false
      t.column :moved_to, :integer, :null => false                  #FK

      t.foreign_key :subpartition_id, :subpartitions, :id
    end 
  end

  def self.down
    drop_table :topics
  end
end
