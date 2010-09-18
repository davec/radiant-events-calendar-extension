module CalendarsHelper
  include CalendarHelper

  def make_calendar(this_month, rjs = false)
    next_month = this_month + 1.month
    last_month = this_month - 1.month

    div_id = 'events-calendar'

    calendar_options = {
      :year => this_month.year,
      :month => this_month.month,
      :previous_month_text => %Q{
<div class="prevMonthName changeMonth">
  <a href="#{calendar_path(:year => last_month.year, :month => last_month.month)}">
    &lt;&nbsp;#{Date::ABBR_MONTHNAMES[last_month.month]}
  </a>
</div>
      }.squish,
      :next_month_text => %Q{
<div class="nextMonthName changeMonth">
  <a href="#{calendar_path(:year => next_month.year, :month => next_month.month)}">
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
          eod = d + 1.day - 1.second
          events << ActionView::Base.new(ActionController::Base.view_paths).render(:partial => 'calendars/events', :locals => { :id => d.jd, :events => days_with_events[d], :end_of_day => eod })

          [ %Q{<a href="/events/#{this_month.year}/#{this_month.month}/#{d.mday}">#{d.mday}</a>}, { :class => 'eventDay', :id => "day-#{d.jd}" } ]
        end
        # HACK around a bug in RedCloth that inserts spurious p tags (the extra newlines seem to avoid the problem)
      end.gsub(/(<\/?(table|thead|tbody|tfoot|tr|th|td)[^>]*?>)/, "\n"+'\1')
      block << "\n"
      block << events.join
      # NOTE: IE does not always see the closing div tag unless it's terminated with a newline
      block << "</div>"
    end
  end

end
