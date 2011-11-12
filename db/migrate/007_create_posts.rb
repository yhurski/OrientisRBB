class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.column :topic_id, :integer, :null => false                        #FK
      t.column :poster, :string, :limit => 25, :null => false
      t.column :poster_id, :integer, :null => false                       #FK
      t.column :message, :text
      t.column :posted, :datetime, :null => false
      t.column :edited, :datetime, :null => true
      t.column :edited_by, :string, :limit => 25, :null => true
      t.column :title, :string, :limit => 50, :null => false
      t.column :created, :datetime, :null => false

    end
  end

  def self.down
    drop_table :posts
  end
end
