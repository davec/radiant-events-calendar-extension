require File.dirname(__FILE__) + '/../spec_helper'

describe EventsPage do
  dataset :events
  test_helper :render

  before :each do
    @request = ActionController::TestRequest.new
    @request.request_uri = "/events/#{Date.today.year}/1/1"
    @page = pages(:events)
    @page.request = @request
  end

  it "should be a virtual page" do
    @page.should be_virtual
  end

  it "should be cached" do
    @page.should be_cache
  end

  it "should find the URL from the homepage" do
    pages(:home).find_by_url(@request.request_uri).should == @page
  end

  it "should render the events for the given day" do
    pages(:home).find_by_url(@request.request_uri).render.should == "New Year's Day"
  end

end
