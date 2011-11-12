class AddColToGroups < ActiveRecord::Migration
  def self.up
      add_column :groups, :is_moder_in_group, :boolean, :default => false
  end

  def self.down
      remove_column :groups, :is_moder_in_group
  end
end
