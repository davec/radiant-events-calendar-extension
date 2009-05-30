require File.dirname(__FILE__) + '/../spec_helper'

describe CalendarsController do
  include ERB::Util
  integrate_views
  dataset :events

  it 'should return a calendar for the given month with an AJAX call' do
    # DANGER: The returned HTML is JSON-encoded. All the backslashes in the
    # substitution really are required to get the correct matcher. Perhaps
    # this is overkill and we don't need to bother checking the return string?
    re = %Q{<th .*?class=\\"monthName\\".*?>#{Date::MONTHNAMES[Date.today.month]}</th>}
    expected = %r{#{json_escape(re).gsub('\\','\\\\\\').sub('\\\\monthName\\\\','\\\\\\\\"monthName\\\\\\\\"')}}

    xhr :get, :show, :year => Date.today.year, :month => Date.today.month
    response.should be_success
    response.should have_rjs(:replace, 'events-calendar')
    response.should have_text(expected)
  end

end
