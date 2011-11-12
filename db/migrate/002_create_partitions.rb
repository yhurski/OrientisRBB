class CreatePartitions < ActiveRecord::Migration
  def self.up
    create_table :partitions, :options => 'ENGINE=InnoDB'  do |t|
      t.column :title, :string, :limit => 255, :null => false
    end        
  end

  def self.down
    drop_table :partitions
  end
end
