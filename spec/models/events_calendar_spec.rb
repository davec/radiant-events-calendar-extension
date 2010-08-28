require File.dirname(__FILE__) + '/../spec_helper'

describe 'EventsCalendar' do
  dataset :pages, :events

  describe '<r:calendar>' do

    it 'should render a calendar for the current month and include events for today' do
      tag = %{<r:calendar />}

      today = Date.today
      expected = %r{\A<div id=\"events-calendar\">.*<th[^>]*>#{Date::MONTHNAMES[today.month]}\n?</th>.*<td[^>]*><a href=\"/events/#{today.year}/#{today.month}/#{today.mday}\">#{today.mday}</a>.*</table>\n?<div class='calendar-data tooltip'.*<\/div>\n?</div>\Z}m

      pages(:home).should render(tag).matching(expected)
    end

    it 'should render a calendar for the specified month and year' do
      tag = %{<r:calendar year='2009' month='1' />}

      expected = %r{\A<div id=\"events-calendar\">.*<th[^>]*>#{Date::MONTHNAMES[1]}\n?</th>.*</table>\n?</div>\Z}m

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

    it 'should not accept nonsense text for a date' do
      tag = %{<r:events for="until the end of time" />}

      pages(:home).should render(tag).with_error('invalid date')
    end

    it 'should accept a bare tag and generate no output' do
      tag = %{<r:events />}
      expected = ''

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
      pages(:home).should render(tag).with_error("the `by' attribute of the `each' tag must be set to a valid field name")
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

  describe '<r:events:each:event:time:start>' do

    it 'should return the event start time in the default format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time:start /></r:each></r:events>}
      expected = "08:00"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event start time in the given format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time:start format='%I:%M %p' /></r:each></r:events>}
      expected = "08:00 AM"

      pages(:home).should render(tag).as(expected)
    end

  end

  describe '<r:events:each:event:time:end>' do

    it 'should return the event end time in the default format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time:end /></r:each></r:events>}
      expected = "17:00"

      pages(:home).should render(tag).as(expected)
    end

    it 'should return the event end time in the given format' do
      tag = %Q{<r:events for='#{Date.today.year}-01-15'><r:each><r:event:time:end format='%I:%M %p' /></r:each></r:events>}
      expected = "05:00 PM"

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
      expected = "<p>New Year's Party</p>"

      pages(:home).should render(tag).as(expected)
    end

    %w(true false).each do |sanitization|
      it %Q{should accept sanitize="#{sanitization}"} do
        tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:description sanitize="#{sanitization}" /></r:each></r:events>}
        expected = "<p>New Year's Party</p>"
        
        pages(:home).should render(tag).as(expected)
      end
    end

    it 'should require a valid value for sanitize' do
      tag = %Q{<r:events for='#{Date.today.year}-01-01'><r:each><r:event:description sanitize="foo" /></r:each></r:events>}
      pages(:home).should render(tag).with_error(%{the `sanitize' attribute of the `description' tag must be either "true" or "false"})
    end

  end

  describe '<r:events:each:event:category>' do

    it 'should return the event category' do
      tag = %Q{<r:events for='#{Date.today.year}-07-04'><r:each><r:event:category /></r:each></r:events>}
      expected = "Holidays"

      pages(:home).should render(tag).as(expected)
    end

  end

  context 'relative date periods' do

    context 'period specification' do

      it 'should accept relative date periods and generate no output' do
        %w(next previous).each do |direction|
          %w(days weeks months years).each do |period|
            tag = %{<r:events for="#{direction} 2 #{period}" />}
            expected = ''

            pages(:home).should render(tag).as(expected)
          end
        end
      end

      it 'should accept the inclusive attribute and generate no output' do
        %w(true false).each do |value|
          tag = %{<r:events for="next 42 days" inclusive="#{value}" />}
          expected = ''

          pages(:home).should render(tag).as(expected)
        end
      end

    end

    context 'locating events' do

      before do
        Event.delete_all
        create_event("Event for today",      Date.today,           :description => "Event for today")
        create_event("Event for yesterday",  Date.today - 1,       :description => "Event for yesterday")
        create_event("Event for last week",  Date.today - 1.week,  :description => "Event for last week")
        create_event("Event for last month", Date.today - 1.month, :description => "Event for last month")
        create_event("Event for last year",  Date.today - 1.year,  :description => "Event for last year")
        create_event("Event for tomorrow",   Date.today + 1,       :description => "Event for tomorrow")
        create_event("Event for next week",  Date.today + 1.week,  :description => "Event for next week")
        create_event("Event for next month", Date.today + 1.month, :description => "Event for next month")
        create_event("Event for next year",  Date.today + 1.year,  :description => "Event for next year")
      end

      it 'should find the correct events for the specified period' do
        [true, false].each do |inclusive|
          %w(next previous).each do |direction|
            %w(days weeks months years).each do |period|
              tag = %{<r:events for="#{direction} 1 #{period}" inclusive="#{inclusive.to_s}"><r:each><r:event:date />,</r:each></r:events>}
              expected = ''
              if direction == "next"
                expected << "#{Date.today.strftime("%Y-%m-%d")}," if inclusive
                expected << "#{(Date.today + 1.day).strftime('%Y-%m-%d')},"
                expected << "#{(Date.today + 1.week).strftime('%Y-%m-%d')}," unless period == "days"
                expected << "#{(Date.today + 1.month).strftime('%Y-%m-%d')}," if %w(months years).include?(period)
                expected << "#{(Date.today + 1.year).strftime('%Y-%m-%d')}," if period == "years"
              else
                expected << "#{(Date.today - 1.year).strftime('%Y-%m-%d')}," if period == "years"
                expected << "#{(Date.today - 1.month).strftime('%Y-%m-%d')}," if %w(months years).include?(period)
                expected << "#{(Date.today - 1.week).strftime('%Y-%m-%d')}," unless period == "days"
                expected << "#{(Date.today - 1.day).strftime('%Y-%m-%d')},"
                expected << "#{Date.today.strftime('%Y-%m-%d')}," if inclusive
              end

              pages(:home).should render(tag).as(expected)
            end
          end
        end
      end

    end

  end

end
