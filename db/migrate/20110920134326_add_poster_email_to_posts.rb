class AddPosterEmailToPosts < ActiveRecord::Migration
  def self.up
      add_column :posts, :poster_email, :string, :limit => 70
  end

  def self.down
      remove_column :posts, :poster_email
  end
end
