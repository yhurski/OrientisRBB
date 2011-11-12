class ChangeColInPosts < ActiveRecord::Migration
  def self.up
	remove_column :posts, :created
	add_column :posts, :poster_ip, :string, :limit => 15, :default => '0.0.0.0', :null => true
  end

  def self.down
	add_column :posts, :created, :datetime, :null => false
	remove_column :posts, :poster_ip
  end
end
