class AddPosterIdToTopics < ActiveRecord::Migration
  def self.up
      add_column :topics, :poster_id, :integer, :null => false, :default => 1
  end

  def self.down
      remove_column :topics, :poster_id
  end
end
