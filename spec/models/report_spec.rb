require 'spec_helper'

describe Report do
  before(:each) do
    @post  = FactoryGirl.create(:post, :topic_id => 1)
    @user  = FactoryGirl.create(:user)
    @report = FactoryGirl.create(:report, :post_id => @post.id, :topic_id => @post.topic.id, :subpartition_id => @post.topic.subpartition.id, :user_id => @user.id)
  end

  it 'should create new report' do
    new_report = Report.create_new({:id => @post.id, :reports => { :message => 'report report report' }}, @user.id)
    new_report.should be_valid
    new_report.message.should be_eql('report report report')
  end
  
  describe 'mark_as_readed method' do
    
    it 'should return nil for illegal user' do
      Report.mark_as_readed({ '1' => 1 }, -1).should be_nil
    end
    
    #{ '1' => 1, '2' => 2 }
    it 'should return nil for illegal hash array' do
      Report.mark_as_readed(nil, @report.id).should be_nil
      Report.mark_as_readed(123456, @report.id).should be_nil
      Report.mark_as_readed('123456', @report.id).should be_nil
    end
    
    it 'should mark all reports as readed' do
      hash_with_id = {}
      Report.all.map(&:id).each{ |el| hash_with_id[el] = el }
      Report.all.map(&:readed_by).select{ |el| el.nil? }.should have_at_least(1).items
      Report.mark_as_readed(hash_with_id, @user.id)
      #debugger
      Report.all.map(&:readed_by).select{ |el| ! el.nil? }.should =~ []
    end
    
  end
  
  it 'should return new (that were not readed) reports' do
    new_report = Report.create_new({:id => @post.id, :reports => { :message => 'report report report' }}, @user.id)
    new_report.should be_valid
    Report.get_new_reports.should have_at_least(1).reports
  end
  
  it 'should return true if contains new reports' do
    hash_with_id = {}
    Report.all.map(&:id).each{ |el| hash_with_id[el] = el }
    Report.is_have_new.should be_true
    Report.mark_as_readed(hash_with_id, @user.id)
    Report.is_have_new.should be_false
  end
    
end
