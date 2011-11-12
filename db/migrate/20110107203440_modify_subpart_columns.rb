class ModifySubpartColumns < ActiveRecord::Migration
  def self.up
    change_column :subpartitions, :last_post, :datetime,  :null => true
    change_column :subpartitions, :last_post_id, :integer, :null => true
    change_column :subpartitions, :last_poster, :string, :limit => 255, :null => true
  end

  def self.down
    change_column :subpartitions, :last_post, :datetime, :null => false
    change_column :subpartitions, :last_post_id, :integer, :null => false
    change_column :subpartitions, :last_poster, :string, :limit => 255, :null => false
  end
end
