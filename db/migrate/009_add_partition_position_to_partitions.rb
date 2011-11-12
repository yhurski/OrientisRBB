class AddPartitionPositionToPartitions < ActiveRecord::Migration

  def self.up
     add_column :partitions, :part_pos, :integer, :null => false, :default => 0
  end

  def self.down
     remove_column :partitions, :part_pos
  end

end