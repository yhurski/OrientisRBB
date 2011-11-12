class AddIsGuestColToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :is_guest, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :is_guest
  end
end
