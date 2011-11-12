require 'spec_helper'

describe Censor do
  before(:all) do
    @cens = FactoryGirl.create(:censor, :source_word => 'uncle faka', :dest_word => 'foobar')
  end

  it { should validate_presence_of(:source_word) }
  it { should validate_presence_of(:dest_word) }
  it { should ensure_length_of(:source_word).is_at_most(60) }
  it { should ensure_length_of(:dest_word).is_at_most(60) }

  it 'should be valid' do
    @cens.should be_valid
  end

  it 'should replace censoring word with destination word' do
    msg = Faker::Lorem.words(4).join(' ') + @cens.source_word + Faker::Lorem.words(4).join(' ')
    Censor.censoring(msg).should_not match(/uncle faka/)
    Censor.censoring(msg).should match(/foobar/)
    msg = Faker::Lorem.words(4).join(' ') + @cens.source_word
    Censor.censoring(msg).should_not match(/uncle faka/)
    Censor.censoring(msg).should match(/foobar/)
    msg = @cens.source_word + Faker::Lorem.words(4).join(' ')
    Censor.censoring(msg).should_not match(/uncle faka/)
    Censor.censoring(msg).should match(/foobar/)
    msg = @cens.source_word
    Censor.censoring(msg).should_not match(/uncle faka/)
    Censor.censoring(msg).should match(/foobar/)
  end
  
end
