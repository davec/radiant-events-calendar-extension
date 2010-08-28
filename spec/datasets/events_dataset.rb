class EventsDataset < Dataset::Base
  uses :home_page

  def load
    create_page "Events", :slug => "events", :title => "Events", :class_name => "EventsPage", :virtual => true do
      create_page_part "events_body", :name => "body", :content => "<r:events:each><r:event:name /></r:events:each>"
    end
    this_year = Date.today.year
    start_of_today = Time.now.at_beginning_of_day
    create_event("Today's first event", Date.today, :start_time => start_of_today + 10.hours, :description => "An event happening today.")
    create_event("Today's second event", Date.today, :start_time => start_of_today + 16.hours, :description => "Another event happening today.")
    create_event("Today's late night event", Date.today, :start_time => start_of_today + 23.hours, :description => "Another event happening today.")
    create_event("Yesterday's event", Date.yesterday, :description => "An event that happened yesterday.")
    create_event("Tomorrow's event", Date.tomorrow, :description => "An event happening tomorrow.")
    create_event("New Year's Day", Date.civil(this_year,1,1), :description => "New Year's Party", :location => "Swanky Hotel", :start_time => Time.local(this_year,1,1,0,0,0))
    create_event("Mid-Jan event", Date.civil(this_year,1,15), :description => "Mid-January event", :start_time => Time.local(this_year,1,15,8,0,0), :end_time => Time.local(this_year,1,15,17,0,0))
    create_event("Independence Day", Date.civil(this_year,7,4), :description => "Fireworks", :location => "Down by the river", :category => "Holidays", :start_time => Time.local(this_year,7,4,20,0,0))
  end

  helpers do
    def create_event(name, date, attributes = {})
      create_model :event, name, attributes.update(:name => name, :date => date, :filter_id => nil)
    end
  end

end
