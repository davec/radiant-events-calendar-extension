module CalendarsHelper
  include CalendarHelper

  def make_calendar(this_month, rjs = false)
    next_month = this_month + 1.month
    last_month = this_month - 1.month

    div_id = 'events-calendar'

    # The JS script to run to construct the tooltips varies depending on whether the
    # response is for HTML or RJS. When responding to HTML, the JS func has to be
    # run after the DOM is loaded (at least on IE6 and IE7, but not IE8, Firefox, or
    # Safari). But when responding to RJS, the JS func has to be invoked directly.
    tooltip_func = 'makeToolTips'.freeze
    tooltip_script = rjs ? "#{tooltip_func}();" : "document.observe('dom:loaded', #{tooltip_func});"

    calendar_options = {
      :year => this_month.year,
      :month => this_month.month,
      :previous_month_text => %Q{
<div class="prevMonthName">
  <a onclick="new Ajax.Request('#{calendar_path(:year => last_month.year, :month => last_month.month)}', { method: 'get' }); return false;"
     href="#{calendar_path(:year => last_month.year, :month => last_month.month)}">
    &lt;&nbsp;#{Date::ABBR_MONTHNAMES[last_month.month]}
  </a>
</div>
      }.squish,
      :next_month_text => %Q{
<div class="nextMonthName">
  <a onclick="new Ajax.Request('#{calendar_path(:year => next_month.year, :month => next_month.month)}', { method: 'get' }); return false;"
     href="#{calendar_path(:year => next_month.year, :month => next_month.month)}">
    #{Date::ABBR_MONTHNAMES[next_month.month]}&nbsp;&gt;
  </a>
</div>
      }.squish,
      :abbrev => (0..1)
    }

    days_with_events = Event.for_month(this_month.month, this_month.year).group_by(&:date)

    returning String.new do |block|
      events = []

      block << %Q{<div id="#{div_id}">}
      block << calendar(calendar_options) do |d|
        if days_with_events.has_key?(d)
          event_list = %Q{<div id="events-#{d.jd}" class="calendar-data tooltip">\n<dl class="events">\n}
          eod = d + 1.day - 1.second
          # Sort events by start time, with full-day events being placed
          # at the end, followed by a secondary sort on the event name.
          days_with_events[d].sort_by{|e| [e.start_time||eod,e.name]}.each do |event|
            event_list << %Q{<dt>#{h event.name}</dt>\n}
            event_list << %Q{<dd class="location">#{h event.location}</dd>\n} if event.location
            event_list << %Q{<dd class="time">#{h event.time(:format => '%l:%M %p')}</dd>\n} if event.time
            event_list << %Q{<dd class="description">#{h(event.description) || '&nbsp;'}</dd>\n}
          end
          event_list << %Q{</dl>\n<p class="footer">Click date for more details</p>\n</div>\n}
          events << event_list

          [ %Q{<a href="#{events_path(:year => this_month.year, :month => this_month.month, :day => d.mday)}">#{d.mday}</a>}, { :class => 'eventDay', :id => "day-#{d.jd}" } ]
        end
        # HACK around a bug in RedCloth that inserts spurious p tags (the extra newlines seem to avoid the problem)
      end.gsub(/(<\/?(table|thead|tbody|tfoot|tr|th|td)[^>]*?>)/, "\n"+'\1')
      block << "\n"
      block << events.join
      block << %Q{<script type="text/javascript">#{tooltip_script}</script>\n}
      block << '</div>'
    end
  end

end
