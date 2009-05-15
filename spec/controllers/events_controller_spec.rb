require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController do
  integrate_views
  dataset :events

  it 'should return a list of events for the given day' do
    get :show, :year => Date.today.year, :month => Date.today.month, :day => Date.today.mday
    response.should be_success
    assigns[:events].should have_at_least(1).event
  end

end
