class AddSignatureToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :signature, :text, :limit => 400, :null => true
  end

  def self.down
    remove_column :users, :signature
  end
end
