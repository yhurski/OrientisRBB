#Administrator
ForumPerm.create(:group_id => Group.get_admin.id,
                                      :subpartition_id => 1,
                                      :read_forum => 1,
                                      :post_replies => 1,
                                      :post_topics => 1)
                                      
#Guests                                      
ForumPerm.create(:group_id => Group.get_guest.id,
                                      :subpartition_id => Subpartition.first,
                                      :read_forum => 1,
                                      :post_replies => 0,
                                      :post_topics => 0)                                      
                                      
#Moderators                                      
ForumPerm.create(:group_id => Group.get_moder.id,
                                      :subpartition_id => Subpartition.first,
                                      :read_forum => 1,
                                      :post_replies => 1,
                                      :post_topics => 1)                                      
                                      
#Members                                      
ForumPerm.create(:group_id => Group.get_member.id,
                                      :subpartition_id => Subpartition.first,
                                      :read_forum => 1,
                                      :post_replies => 1,
                                      :post_topics => 1)                                      