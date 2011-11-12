class CreateConfigs < ActiveRecord::Migration
  def self.up
    create_table :configs do |t|
      t.string :name, :limit => 255, :null => false
      t.text :value	
    end
  end

  def self.down
    drop_table :configs
  end
end
