class CreateModerators < ActiveRecord::Migration
  def self.up
    create_table :subpartitions_users, :id => false do |t|
        t.integer :subpartition_id, :null => false
        t.integer :user_id, :null => false
    end
  end

  def self.down
    drop_table :subpartitions_users
  end
end
