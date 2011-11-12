class CreateBans < ActiveRecord::Migration
  def self.up
    create_table :bans do |t|
        t.string :username, :limit => 25
        t.string :ip, :limit => 15
        t.string :email, :limit => 50
        t.string :message, :limit => 255
        t.datetime :expire
        t.integer :ban_creator, :null => false
    end
  end

  def self.down
    drop_table :bans
  end
end
