class AddRealnameLocationWebsiteFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :realname, :string, :limit => 100, :null => true
    add_column :users, :location, :string, :limit => 100, :null => true
    add_column :users, :web, :string, :limit => 255, :null => true
  end

  def self.down
    remove_column :users, :realname
    remove_column :users, :location
    remove_column :users, :web
  end
end
