class CreateCensors < ActiveRecord::Migration
  def self.up
    create_table :censors do |t|
      t.string :source_word, :limit => 60, :null => false
      t.string :dest_word, :limit => 60, :null => false
    end
  end

  def self.down
    drop_table :censors
  end
end
