class ChangeColInBans < ActiveRecord::Migration
  def self.up
    change_column :bans, :ip, :string, :limit => 255, :default => "0.0.0.0", :null => false
  end

  def self.down
     change_column :bans, :ip, :null => true
  end
end
