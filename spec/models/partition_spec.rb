require 'spec_helper'

describe Partition do
  before(:each) do
    @group = FactoryGirl.create(:group)
    @partition = FactoryGirl.create(:partition)
    @subpartition = FactoryGirl.create(:subpartition, :partition_id => @partition.id)
    @perms = FactoryGirl.create(:forum_perm, :group_id => @group.id, :subpartition_id => @subpartition.id, :read_forum => true,
                                            :post_replies => true, :post_topics => true)
  end
  
  it { should have_many(:subpartitions).dependent(:destroy) }
  it { should validate_presence_of(:title).with_message('Title field must be present') }
  it { should ensure_length_of(:title).is_at_most(255).with_message('Title field is too long') }
  it { should validate_numericality_of(:part_pos).with_message("It's not numerical value") }
  it { should validate_uniqueness_of(:part_pos).with_message('You already have forum with such position') }

  describe 'drop_denied_subpartitions method' do

    it 'should return nil for illegal parameter' do
      @partition.drop_denied_subpartitions(nil).should be_nil
      @partition.drop_denied_subpartitions(0).should be_nil
      @partition.drop_denied_subpartitions('0').should be_nil
    end
    
    it 'should return nil if all subpartition is allowed to read by user group' do
      @partition.drop_denied_subpartitions(@group.id).should be_nil
      @perms.update_attributes(:read_forum => false).should be_true
      @partition.drop_denied_subpartitions(@group.id).should have_at_least(1).subpartitions
    end
  
  end
  
end
