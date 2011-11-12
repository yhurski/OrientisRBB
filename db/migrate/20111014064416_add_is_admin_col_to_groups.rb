class AddIsAdminColToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :is_admin, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :is_admin
  end
end
