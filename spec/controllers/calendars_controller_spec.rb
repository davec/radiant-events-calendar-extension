require File.dirname(__FILE__) + '/../spec_helper'

describe CalendarsController do
  integrate_views
  dataset :events

  before(:each) do
    @today = Date.today
    request.env['HTTP_REFERER'] = 'http://test.host/'
  end

  describe "routing" do
    it 'should route to the show action' do
      params_from(:get, "/calendar/#{@today.year}/#{@today.month}").should == { :controller => 'calendars', :action => 'show', :year => @today.year.to_s, :month => @today.month.to_s }
    end
  end

  describe "via AJAX" do
    it 'should return a calendar for the given month' do
      expected = %r{<th .*?class="monthName".*?>#{Date::MONTHNAMES[@today.month]}\n?</th>}

      xhr :get, :show, :year => @today.year, :month => @today.month
      response.should be_success
      response.should have_text(expected)
    end
  end

  describe "via non-AJAX" do
    it 'should redirect to the referring page, setting session params to generate a calendar for the given month' do
      date = Date.today + 1.month
      expected = %r{<th .*?class="monthName".*?>#{Date::MONTHNAMES[date.month]}\n?</th>}

      get :show, :year => date.year, :month => date.month
      response.should redirect_to(request.referer)
      session[:calendar_view].should == { :year => date.year.to_s, :month => date.month.to_s }
    end
  end
end
