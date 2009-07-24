require File.dirname(__FILE__) + '/../spec_helper'

describe 'EventsCalendar' do
  dataset :pages, :events

  describe '<r:calendar>' do

    it 'should render a calendar for the current month and include events for today' do
      tag = %{<r:calendar />}

      today = Date.today
      expected = %r{\A<div id=\"events-calendar\">.*<th[^>]*>#{Date::MONTHNAMES[today.month]}\n?</th>.*<td[^>]*><a href=\"/events/#{today.year}/#{today.month}/#{today.mday}\">#{today.mday}</a>.*</div>\n?<script type=\"text/javascript\">.*</script>\n?</div>\Z}m

      pages(:home).should render(tag).matching(expected)
    end

    it 'should render a calendar for the specified month and year' do
      tag = %{<r:calendar year='2009' month='1' />}

      expected = %r{\A<div id=\"events-calendar\">.*<th[^>]*>#{Date::MONTHNAMES[1]}\n?</th>.*</div>\n?<script type=\"text/javascript\">.*</script>\n?</div>\Z}m

      pages(:home).should render(tag).matching(expected)
    end

    it 'should not accept an invalid date' do
      tag = %{<r:calendar year='2010' month='13' />}

      pages(:home).should render(tag).with_error('invalid date')
    end

    tag_pairs = {
      %{year}  => %{<r:calendar year='2009' />},
      %{month} => %{<r:calendar month='12' />}
    }

    tag_pairs.each do |spec,tag|
      it "should not accept a date specification with only a #{spec}" do
        pages(:home).should render(tag).with_error('the calendar tag requires a month and year to be specified')
      end
    end

    it 'should require a month' do
      tag = %{<r:calendar year='2009' />}

      pages(:home).should render(tag).with_error('the calendar tag requires a month and year to be specified')
    end

  end

  describe '<r:events>' do

    it 'should not accept an incomplete date' do
      tag = %{<r:events for='2000-' />}

      pages(:home).should render(tag).with_error('invalid date')
    end

    it 'should not accept an invalid date' do
      tag = %{<r:events for='2010-13-42' />}

      pages(:home).should render(tag).with_error('invalid date')
    end

    it 'should use today when for="today"' do
      tag = %{<r:events for='today'><r:each><r:event:name /></r:each></r:events>}
      expected = %w{first second late\ night}.collect{ |x| "Today's #{x} event" }.join

      pages(:home).should render(tag).as(expected)
    end

    it 'should use tomorrow when for="tomorrow"' do
      tag = %{<r:events for='tomorrow'><r:each><r:event:name /></r:each></r:events>}
      expected = "Tomorrow's event"

      pages(:home).should render(tag).as(expected)
    end

    it 'should use yesterday when for="yesterday"' do
      tag = %{<r:events for='yesterday'><r:each><r:event:name /></r:each></r:events>}
      expected = "Yesterday's event"

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept a fully-qualified date and generate no output' do
      tag = %{<r:events for='2009-01-15' />}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should accept a bare tag and generate no output' do
      tag = %{<r:events />}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

    it 'should yield all events by default' do
      tag = %{<r:events><r:each><r:event:name/></r:each></r:events>}
      expected = Event.all.collect(&:name).join

      pages(:home).should render(tag).as(expected)
    end

    it 'should yield events ascendingly by date' do
      tag = %{<r:events by='date'><r:each><r:event:name/></r:each></r:events>}
      expected = Event.all(:order => 'date').collect(&:name).join

      pages(:home).should render(tag).as(expected)
    end

    it 'should yield events descendingly by date' do
      tag = %{<r:events by='date' order="desc"><r:each><r:event:name/></r:each></r:events>}
      expected = Event.all(:order => 'date DESC').collect(&:name).join

      pages(:home).should render(tag).as(expected)
    end

    it 'should require a valid field name for the by attribute' do
      tag = %{<r:events by='pants'><r:each><r:event:name/></r:each></r:events>}
      pages(:home).should render(tag).with_error("`by' attribute of `each' tag must be set to a valid field name")
    end

    it 'should require a valid order attribute' do
      tag = %{<r:events by='date' order="blargh"><r:each><r:event:name/></r:each></r:events>}
      pages(:home).should render(tag).with_error(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
    end

    it 'should limit number of events' do
      tag = %{<r:events limit="1"><r:each><r:event:name/></r:each></r:events>}
      expected = Event.first.name

      pages(:home).should render(tag).as(expected)
    end

    it 'should offset number of events' do
      tag = %{<r:events limit="1" offset="1"><r:each><r:event:name/></r:each></r:events>}
      expected = Event.all[1].name

      pages(:home).should render(tag).as(expected)
    end

    it 'should restrict events by category' do
      tag = %{<r:events category="Holidays"><r:each><r:event:name/></r:each></r:events>}
      expected = "Independence Day"

      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:events:each>' do

    it 'should generate no output' do
      tag = %{<r:events><r:each></r:each></r:events>}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:name>' do

    it 'should return the event name' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:name /></r:each></r:events>}
      expected = "New Year's Day"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:date>' do

    it 'should return the event date in the default format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:date /></r:each></r:events>}
      expected = "#{Date.today.year}-01-01"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event date in the given format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:date format='%d %b %Y' /></r:each></r:events>}
      expected = "01 Jan #{Date.today.year}"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:time>' do

    it 'should return the event time in the default format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:time /></r:each></r:events>}
      expected = "00:00"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event time in the given format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:time format='%I:%M %p' /></r:each></r:events>}
      expected = "12:00 AM"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event time as a range' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time /></r:each></r:events>}
      expected = "08:00 - 17:00"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event time as a range using the specified connector' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time connector='to' /></r:each></r:events>}
      expected = "08:00 to 17:00"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:location>' do

    it 'should return the event location' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:location /></r:each></r:events>}
      expected = "Swanky Hotel"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:description>' do

    it 'should return the event description' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:description /></r:each></r:events>}
      expected = "New Year's Party"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:category>' do

    it 'should return the event category' do
      tag = %Q{<r:events for='#{Date.today.year}-07-04'><r:each><r:event:category /></r:each></r:events>}
      expected = "Holidays"

      pages(:home).should render(tag).as(expected)
    end

  end

end
