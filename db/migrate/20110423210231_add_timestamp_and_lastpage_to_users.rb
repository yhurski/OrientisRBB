class AddTimestampAndLastpageToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :last_visit, :datetime
      add_column :users, :last_page, :string
  end

  def self.down
      remove_column :users, :last_visit
      remove_column :users, :last_page
  end
end
