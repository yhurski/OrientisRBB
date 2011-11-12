class AddRemindEmailSendedToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :remind_pass_sended, :boolean, :default => false
  end

  def self.down
      remove_column :users, :remind_pass_sended
  end
end
