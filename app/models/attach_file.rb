class AttachFile < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :post
    
  has_attached_file :attach, :styles => lambda{|attach| if attach && MimeMagic.by_path(attach.instance.attach_file_name) && MimeMagic.by_path(attach.instance.attach_file_name).image? then {:thumb => Configs.get_attach_image_size}else {} end}

    
  def self.save_attach params, post_id, user_group
    return if(params[:attach].blank? || ! Post.exists?(post_id) || ! Group.exists?(user_group))
    new_attach = AttachFile.new(params[:attach])
    if user_group.attach_upload_max_size > 0 && user_group.attach_upload_max_size < new_attach.attach_file_size
      return I18n.t(:size_is_greater)
    end
    new_attach.update_attributes(:attach_updated_at => Time.now.utc, :post_id => post_id, :user_id => Post.find(post_id).user.id,
      :topic_id => Post.find(post_id).topic.id, :download_counter => 0)
  end
    
  def self.filter_by param
    return nil if ! param.kind_of?(Hash) || param[:attach].blank?
    where_arr = []
    between_clause = '1=1'
    if param[:attach][:max_size].to_i >= param[:attach][:min_size].to_i
      if param[:attach][:max_size] =~ /^\d+$/ && param[:attach][:min_size] =~ /^\d+$/
        between_clause = "attach_file_size BETWEEN #{param[:attach][:min_size].to_i} AND #{param[:attach][:max_size].to_i}"
      end
    end
    if param[:attach][:user].to_i > 0 && User.exists?(param[:attach][:user])
      if param[:attach][:topic].to_i > 0 && Topic.exists?(param[:attach][:topic])
        where_arr = ["#{between_clause} AND user_id = ? AND topic_id = ?", param[:attach][:user], param[:attach][:topic]]
      else
        where_arr = ["#{between_clause} AND user_id = ?", param[:attach][:user]]
      end
    else
      if param[:attach][:topic].to_i > 0 && Topic.exists?(param[:attach][:topic])
        where_arr = ["#{between_clause} AND topic_id = ?", param[:attach][:topic]]
      else
        where_arr = ["#{between_clause}"]
      end
    end
    if param[:attach].has_key?(:orderby) && param[:attach].has_key?(:order)
      find(:all, :conditions => where_arr, :order => "#{param[:attach][:orderby]} #{param[:attach][:order]}")
    else
      find(:all, :conditions => where_arr)
    end
  end
end
