require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::EventsController do
  dataset :users

  before(:each) do
    login_as :admin
  end

  describe "create" do
    it "should be successful" do
      event_name = "Event 1"
      post :create, :event => {
        :name             => event_name,
        :date             => Date.today.to_s(:long),
        :'start_time(5i)' => "09:00:00",
        :'end_time(5i)'   => "17:00:00",
        :timezone         => "UTC"
      }
      response.should redirect_to(admin_events_url)
      Event.find_by_name(event_name).should_not be_nil
    end

    it "should advance an end time to the next day" do
      event_name = "Spanning midnight"
      post :create, :event => {
        :name             => event_name,
        :date             => Date.today.to_s(:long),
        :'start_time(5i)' => "19:00:00",
        :'end_time(5i)'   => "01:00:00",
        :timezone         => "UTC"
      }
      event = Event.find_by_name(event_name)
      event.should_not be_nil
      event.start_time.to_date.should == Date.today
      event.end_time.to_date.should == Date.tomorrow
    end
  end
end
