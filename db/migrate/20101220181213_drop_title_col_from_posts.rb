class DropTitleColFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :title
  end

  def self.down
    add_column :posts, :title, :string, :limit => 50, :null => false
  end
end
