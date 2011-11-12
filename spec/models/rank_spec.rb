require 'spec_helper'

describe Rank do
  before(:all) do
    @rank = FactoryGirl.create(:rank)
  end

  it { should validate_presence_of(:rank) }
  it { should validate_presence_of(:num_of_posts) }
  it { should validate_numericality_of(:num_of_posts) }
  it { should validate_uniqueness_of(:num_of_posts) }

  it 'should be valid' do
    @rank.should be_valid
  end


end
