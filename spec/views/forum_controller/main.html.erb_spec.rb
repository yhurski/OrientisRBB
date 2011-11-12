require 'spec_helper'

describe "/forum_controller/main" do
  before(:each) do
    render 'forum_controller/main'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/forum_controller/main])
  end
end
