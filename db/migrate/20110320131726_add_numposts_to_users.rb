class AddNumpostsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :numposts, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :users, :numposts
  end
end
