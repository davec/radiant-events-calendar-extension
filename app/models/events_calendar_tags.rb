module EventsCalendarTags
  include Radiant::Taggable
  include CalendarsHelper

  class TagError < StandardError ; end

  desc %{
    Gives access to all events, sorted by start_time by default.

    The `for` attribute can be any of the following:
    * "today"
    * "tomorrow"
    * "yesterday"
    * a date in this format: "YYYY-MM-DD" (ex: 2009-03-14)
    * a specified number of days, weeks, months, or years either in the future or past (e.g., "next 2 weeks", "previous 7 days")

    The `inclusive` attribute applies to relative `for` values. If set to `true` (the default) then `today` is included; otherwise `today` is excluded.

    <pre><code><r:events [for="date" [inclusive="true|false"]] [by="attribute"] [order="asc|desc"] [limit="number"] [offset="number"]/></code></pre>
  }
  tag 'events' do |tag|
    tag.locals.events = Event.all(events_find_options(tag))
    tag.expand
  end

  desc %{
    Loops through events.
  }
  tag 'events:each' do |tag|
    tag.locals.events.collect do |event|
      tag.locals.event = event
      tag.expand
    end
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
    Renders the category for the current event.
  }
  tag 'event:category' do |tag|
    event = tag.locals.event
    event.category
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

  private
    def events_find_options(tag)
      attr = tag.attr.symbolize_keys

      options = {}
      where_clauses = []
      where_values = []

      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end

      by = (attr[:by] || 'start_time').strip
      order = (attr[:order] || 'asc').strip
      order_string = ""
      if Event.column_names.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string

      if attr[:for]
        if attr[:for] =~ /\A(next|previous)\s+(\d+)\s+(day|week|month|year)s?\z/
          direction, count, interval = $1, $2.to_i, $3
          include_today = (attr[:inclusive] || "true") == "true"
          if direction == "next"
            start_date = include_today ? Date.today : Date.today + 1
            end_date = Date.today + count.send(interval)
          else
            start_date = Date.today - count.send(interval)
            end_date = include_today ? Date.today : Date.today - 1
          end

          where_clauses << "date >= ?" << "date <= ?"
          where_values << start_date << end_date
        else
          date = case attr[:for]
                 when "today"
                   Date.today
                 when "yesterday"
                   Date.today - 1
                 when "tomorrow"
                   Date.today + 1
                 else
                   parts = attr[:for].split("-")
                   raise TagError, "invalid date" unless parts.length == 3
                   Date.civil(*parts.collect(&:to_i))
                 end

          where_clauses << "date = ?"
          where_values  << date
        end
      end

      if attr[:category]
        where_clauses << "category = ?"
        where_values  << attr[:category]
      end

      if !where_clauses.empty?
        options[:conditions] = [where_clauses.join(" AND ")] + where_values
      end

      options
    end
end
