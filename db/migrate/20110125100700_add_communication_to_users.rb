class AddCommunicationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :jabber, :string, :limit => 50
    add_column :users, :icq, :string, :limit => 15
    add_column :users, :msn, :string, :limit => 50
    add_column :users, :aim, :string, :limit => 30
    add_column :users, :yahoo, :string, :limit => 30
  end

  def self.down
    remove_column :users, :jabber
    remove_column :users, :icq
    remove_column :users, :msn
    remove_column :users, :aol
    remove_column :users, :yahoo
  end
end
