class AddViewFromProfileElemsToUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :forum_style, :string, :limit => 50
      add_column :users, :smiles_to_img, :boolean, :default => true
      add_column :users, :show_users_sign, :boolean, :default => true
      add_column :users, :show_img_inmess, :boolean, :default => true
      add_column :users, :show_img_insign, :boolean, :default => true
      add_column :users, :themes_per_page, :integer
      add_column :users, :posts_per_page, :integer
  end

  def self.down
    remove_column :users, :forum_style
    remove_column :users, :smiles_to_img
    remove_column :users, :show_users_sign
    remove_column :users, :show_img_inmess
    remove_column :users, :show_img_insign
    remove_column :users, :themes_per_page
    remove_column :users, :posts_per_page
  end
end
