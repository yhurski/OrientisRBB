class CreateRanksTable < ActiveRecord::Migration
  def self.up
    create_table :ranks, :force => true do |t|
        t.string :rank, :limit => 50, :null => false
        t.integer :num_of_posts, :null => false
    end
  end

  def self.down
      drop_table :ranks
  end
end
