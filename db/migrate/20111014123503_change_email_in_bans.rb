class ChangeEmailInBans < ActiveRecord::Migration
  def self.up
    change_column :bans, :email, :string, :limit => 70, :null => true
  end

  def self.down
    change_column :bans, :email, :string, :limit => 50, :null => true
  end
end
