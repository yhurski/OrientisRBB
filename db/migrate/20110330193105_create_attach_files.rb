class CreateAttachFiles < ActiveRecord::Migration
  def self.up
    create_table :attach_files do |t|
      t.integer :user_id, :null => false
      t.integer :post_id, :null => false
      t.integer :topic_id, :null => false
      t.string :attach_file_name
      t.integer :attach_file_size
      t.string :attach_content_type
      t.datetime :attach_updated_at
      t.integer :download_counter, :null => false      
    end
  end

  def self.down
    drop_table :attach_files
  end
end
