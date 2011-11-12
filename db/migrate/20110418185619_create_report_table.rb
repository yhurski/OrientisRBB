class CreateReportTable < ActiveRecord::Migration
  #TODO: add column index
  def self.up
      create_table :reports do |t|
          t.integer :post_id, :null => false
          t.integer :topic_id, :null => false
          t.integer :subpartition_id, :null => false
          t.integer :user_id, :null => false
          t.datetime :created_at, :null => false
          t.text :message
          t.datetime :readed_at
          t.integer :readed_by
      end
  end

  def self.down
      drop_table :reports
  end
end
