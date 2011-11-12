class AddPartPosColumnToSubpartitions < ActiveRecord::Migration
  def self.up
    add_column :subpartitions, :part_pos, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :subpartitions, :part_pos
  end

end
