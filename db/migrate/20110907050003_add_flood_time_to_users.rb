class AddFloodTimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_post, :datetime
    add_column :users, :last_search, :datetime
    add_column :users, :last_email_sent, :datetime
  end

  def self.down
    remove_column :users, :last_email_sent
    remove_column :users, :last_search
    remove_column :users, :last_post
  end
end
