require 'spec_helper'

describe Session do

  it 'should be valid' do
    session = FactoryGirl.create(:session)
    session.should be_valid
  end

end
