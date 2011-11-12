class Report < ActiveRecord::Base
  belongs_to :post
  belongs_to :topic
  belongs_to :subpartition
  belongs_to :user, :foreign_key => 'user_id'
    
  validates_presence_of :message
    
  def self.create_new param, user_obj
    create(:post_id => param[:id].to_i, :topic_id => Post.find(param[:id].to_i).topic.id, :subpartition_id => Post.find(param[:id].to_i).topic.subpartition.id,
      :user_id => user_obj.id, :created_at => Time.now.utc,  :message => param[:reports][:message])
  end

  def self.mark_as_readed(hash_with_id, user_id)
    return nil unless User.exists?(user_id)
    return nil unless hash_with_id.kind_of?(Hash)
    hash_with_id.each_key do |report_id|
      if Report.exists? report_id
        Report.update(report_id, :readed_at => Time.now.utc, :readed_by => user_id)
      end
    end
  end
    
  def self.get_new_reports
    all.select{|report| report.readed_at.nil?}.sort{|r1, r2| r2.created_at <=> r1.created_at}
  end
    
  def self.is_have_new
    ! find(:first, :conditions => ['readed_at is null']).nil?
  end
end