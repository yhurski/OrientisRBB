class ForumPerm < ActiveRecord::Base
  set_table_name :forum_perms

  belongs_to :group
  belongs_to :subpartition
    
  def self.save_groups_permissions par, subpart_id
    return nil unless par
    colnames = [:read_forum, :post_replies, :post_topics]
    par.each do |group_id, value|
      subpartition_perms = self.find(:first, :conditions => ['group_id = ? and subpartition_id = ?', group_id.to_i, subpart_id.to_i])
      colnames.each do |colname|
        if !par[group_id][colname].nil? && par[group_id][colname].to_bool
          subpartition_perms.update_attribute(colname, true)
        else
          subpartition_perms.update_attribute(colname, false)
        end
      end
    end
    nil
  end
end