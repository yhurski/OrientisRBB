class AddColumnsToGroups < ActiveRecord::Migration
  def self.up
     add_column :groups, :attach_allow_download, :boolean, :default => 0      
     add_column :groups, :attach_allow_upload, :boolean, :default => 0       
#     add_column :groups, :attach_allow_delete, :boolean, :default => 0
     add_column :groups, :attach_allow_delete_own, :boolean, :default => 0     
     add_column :groups, :attach_upload_max_size, :integer, :defalult => 50000     
     add_column :groups, :attach_files_per_post, :integer,  :default => 1   
     add_column :groups, :attach_disallowed_extensions, :text
  end

  def self.down
      remove_column :groups, :attach_allow_download
      remove_column :groups, :attach_allow_upload
   #   remove_column :groups, :attach_allow_delete
      remove_column :groups, :attach_allow_delete_own
      remove_column :groups, :attach_upload_max_size
      remove_column :groups, :attach_files_per_post
      remove_column :groups, :attach_disallowed_extensions
  end
end
