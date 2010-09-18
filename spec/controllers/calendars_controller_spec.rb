require File.dirname(__FILE__) + '/../spec_helper'

describe CalendarsController do
  integrate_views
  dataset :events

  it 'should return a calendar for the given month with an AJAX call' do
    date = Date.today
    expected = %r{<th .*?class="monthName".*?>#{Date::MONTHNAMES[date.month]}\n?</th>}

    xhr :get, :show, :year => date.year, :month => date.month
    response.should be_success
    response.should have_text(expected)
  end

  it 'should return a calendar for the given month with a non-AJAX call' do
    date = Date.today + 1.month
    expected = %r{<th .*?class="monthName".*?>#{Date::MONTHNAMES[date.month]}\n?</th>}

    get :show, :year => date.year, :month => date.month
    response.should be_success
    response.should have_text(expected)
  end

end
