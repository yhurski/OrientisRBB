class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
       t.column :name, :string, :limit => 25, :null => false
       t.column :passwd, :string, :limit => 32, :null => false                #20 - for crypt method 
       t.column :email, :string, :limit => 70, :null => false
       t.column :regdatetime, :datetime, :null => false
       t.column :salt, :string, :limit => 5, :null => false
    end
  end

  def self.down
    drop_table :users
  end
end
