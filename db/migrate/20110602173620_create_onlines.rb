class CreateOnlines < ActiveRecord::Migration
  def self.up
    create_table :onlines do |t|
        t.integer :user_id, :null => false, :default => 0
        t.string   :name, :limit => 25, :null => false
        t.text :prev_url
        t.datetime :last_visit, :null => false
        t.datetime :last_post
        t.datetime :last_search
    end
    
#    add_index :onlines, :user_id
#    add_index :onlines, :name
  end

  def self.down
    drop_table :onlines
  end
end
