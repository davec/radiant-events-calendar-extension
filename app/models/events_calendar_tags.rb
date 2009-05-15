module EventsCalendarTags
  include Radiant::Taggable
  include CalendarsHelper
      
  class TagError < StandardError ; end

  desc %{
    Get all events for the given day.
    If no date is given, the current day is used.

    *Usage:*
    <pre><code><r:events /></code></pre>
    <pre><code><r:events year='2009' month='3' day='15' /></code></pre>
  }
  tag 'events' do |tag|
    options = [ tag.attr['year'], tag.attr['month'], tag.attr['day'] ].compact
    raise TagError, "the events tag requires the date to be fully specified" unless options.empty? || options.length == 3

    year  = (tag.attr['year']  || Date.today.year).to_i
    month = (tag.attr['month'] || Date.today.month).to_i
    day   = (tag.attr['day']   || Date.today.day).to_i

    tag.locals.date = Date.civil(year,month,day)
    tag.expand
  end

  desc %{
    Loops through each event and renders the contents.
  }
  tag 'events:each' do |tag|
    result = []
    Event.for_date(tag.locals.date).each do |event|
      tag.locals.event = event
      result << tag.expand
    end
    result
  end

  desc %{
    Creates the context for a single event.
  }
  tag 'events:each:event' do |tag|
    tag.expand
  end

  desc %{
    Renders the name for the current event.
  }
  tag 'event:name' do |tag|
    event = tag.locals.event
    event.name
  end

  desc %{
    Renders the date for the current event.
    An optional date format string may be specified.
    The default format string is <code>%Y-%m-%d</code>.

    *Usage:*
    <pre><code><r:event:date /></code></pre>
    <pre><code><r:event:date format='%d %b %Y' /></code></pre>
  }
  tag 'event:date' do |tag|
    event = tag.locals.event
    format = tag.attr['format'] || '%Y-%m-%d'
    event.date.strftime(format)
  end

  desc %{
    Renders the time for the current event.
    An optional time format string and time connector, for time ranges, may be specified.
    The default format string is <code>%H:%M</code> and the default connector is <code>-</code> (hyphen).
    The time connector is only used when an event has both a start time and an end time.

    *Usage:*
    <pre><code><r:event:time /></code></pre>
    <pre><code><r:event:time format='%I:%M %p' connector='to' /></code></pre>
  }
  tag 'event:time' do |tag|
    event = tag.locals.event
    return '' unless event.start_time

    format = tag.attr['format'] || '%H:%M'
    [ event.start_time.strftime(format),
      event.end_time ? event.end_time.strftime(format) : nil ].compact.join(" #{tag.attr['connector'] || '-'} ")
  end

  desc %{
    Renders the location for the current event.
  }
  tag 'event:location' do |tag|
    event = tag.locals.event
    event.location
  end

  desc %{
    Renders the description for the current event.
  }
  tag 'event:description' do |tag|
    event = tag.locals.event
    event.description
  end

  desc %{
    Creates a calendar for the given month.
    If no date is given, the current month is used.

    *Usage:*
    <pre><code><r:calendar /></code></pre>
    <pre><code><r:calendar year='2009' month='1' /></code></pre>
  }
  tag 'calendar' do |tag|
    options = [ tag.attr['year'], tag.attr['month'] ].compact
    raise TagError, "the calendar tag requires a month and year to be specified" unless options.empty? || options.length == 2

    year  = (tag.attr['year']  || Date.today.year).to_i
    month = (tag.attr['month'] || Date.today.month).to_i

    date = Date.civil(year, month)
    make_calendar(date)
  end

end
