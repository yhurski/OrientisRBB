class AddNewFieldsToUsers < ActiveRecord::Migration
  def self.up      
      add_column :users, :group_id, :integer, :null => false
      add_column :users, :registration_ip, :string, :limit => 20, :null => false, :default => '0.0.0.0'
      add_column :users, :date_format, :string, :limit => 30, :null => false, :default => '%Y-%m-%d'
      add_column :users, :time_format, :string, :limit => 30, :null => false, :default => '%H:%M:%S'
      add_column :users, :adminnote, :string
  end

  def self.down
      remove_column :users, :group_id
      remove_column :users, :registration_ip
      remove_column :users, :date_format
      remove_column :users, :time_format
      remove_column :users, :adminnote
  end
end
