class AddColumnsToSubpartitions < ActiveRecord::Migration
  def self.up
      add_column :subpartitions, :last_post, :datetime, :null => false
      add_column :subpartitions, :last_post_id, :integer, :null => false              
      add_column :subpartitions, :last_poster, :string, :limit => 25, :null => false
  end

  def self.down
      remove_column :subpartitions, :last_post
      remove_column :subpartitions, :last_post_id
      remove_column :subpartitions, :last_poster
  end
end
