require 'spec_helper'

describe "/addendum/search" do
  before(:each) do
    render 'addendum/search'
  end

  #Delete this example and add some real ones or delete this file
  it 'should tell you where to find the file' do
    debugger
    response.should have_tag('html')
  end
end
