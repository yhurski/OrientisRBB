class CreateSubpartitions < ActiveRecord::Migration
  def self.up
    create_table :subpartitions do |t|
      t.column :partition_id, :integer, :null => false
      t.column :title, :string, :limit => 255, :null => false
      t.column :desc, :string
    end
  end

  def self.down
    drop_table :subpartitions
  end
end
