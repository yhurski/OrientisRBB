class AddRegistrationColumnsToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :timezone, :string, :limit => 80
      add_column :users, :forum_lang, :string, :limit => 10
      add_column :users, :howshowemail, :string, :limit => 1
      # add_column :users, :savecookies, :boolean
  end

  def self.down
    remove_column :users, :timezone
    remove_column :users, :forum_lang
    remove_column :users, :howshowemail
    # remove_column :users, :savecookies
  end
end
