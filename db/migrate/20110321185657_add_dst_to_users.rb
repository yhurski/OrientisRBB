class AddDstToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :dst, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :dst
  end
end
