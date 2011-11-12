class AddTitleToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :title, :string, :limit => 50
  end

  def self.down
      remove_column :users, :title
  end
end
