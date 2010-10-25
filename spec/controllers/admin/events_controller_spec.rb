require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::EventsController do
  dataset :users

  before(:each) do
    login_as :admin
  end

  def default_attributes
    {
      :category         => "",
      :location         => "",
      :date             => Date.today.to_s(:long),
      :'start_time(5i)' => "",
      :'end_time(5i)'   => "",
      :timezone         => "UTC",
      :filter_id        => "",
      :description      => ""
    }
  end

  describe "create" do
    integrate_views

    it "should be successful" do
      event_name = "Event 1"
      post :create, :event => default_attributes.merge({
        :name             => event_name,
        :'start_time(5i)' => "09:00:00",
        :'end_time(5i)'   => "17:00:00"
      })
      response.should redirect_to(admin_events_url)
      event = Event.find_by_name(event_name)
      event.should_not be_nil
      event.start_time.to_date.should == event.end_time.to_date
    end

    it "should advance an end time to the next day" do
      event_name = "Spanning midnight"
      post :create, :event => default_attributes.merge({
        :name             => event_name,
        :date             => Date.today.end_of_year.to_s(:long),
        :'start_time(5i)' => "19:00:00",
        :'end_time(5i)'   => "01:00:00"
      })
      event = Event.find_by_name(event_name)
      event.should_not be_nil
      event.start_time.to_date.should == Date.today.end_of_year
      event.end_time.to_date.should == (Date.today >> 12).beginning_of_year
    end

    it "should not accept same start time and end time" do
      post :create, :event => default_attributes.merge({
        :name => "Same start and end times",
        :'start_time(5i)' => "19:00:00",
        :'end_time(5i)'   => "19:00:00"
      })
      response.should render_template("new")
      response.body.should have_text(/The event's start time must be earlier than its end time/)
    end

    it "should require a start time with an end time" do
      post :create, :event => default_attributes.merge({
        :name => "No start time with end time",
        :'end_time(5i)' => "19:00:00"
      })
      response.should render_template("new")
      response.body.should have_text(/The event's start time must be specified when an end time is specified/)
    end
  end
end
