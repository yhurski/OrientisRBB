class Partition < ActiveRecord::Base
  has_many :subpartitions, :dependent => :destroy

  validates_presence_of      :title
  validates_length_of          :title, :maximum => 255, :allow_nil => false, :allow_blank => false
  validates_numericality_of  :part_pos, :integer_only => true
  validates_uniqueness_of   :part_pos

  def drop_denied_subpartitions group_id
    if Group.exists? group_id
      group_permissions = Group.find(group_id).forum_perms
    else
      return nil
    end
    self.subpartitions.delete_if{|subpartition| !group_permissions.find_by_subpartition_id(subpartition.id).read_forum}
  end
end
