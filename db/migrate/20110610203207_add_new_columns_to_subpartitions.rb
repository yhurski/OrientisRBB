class AddNewColumnsToSubpartitions < ActiveRecord::Migration
  def self.up
      add_column :subpartitions, :num_posts, :integer, :null => false, :default => 0
      add_column :subpartitions, :num_topics, :integer, :null => false, :default => 0
  end

  def self.down
      remove_column :subpartitions, :num_posts
      remove_column :subpartitions, :num_topics
  end
end
