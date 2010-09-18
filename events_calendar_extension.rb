class EventsCalendarExtension < Radiant::Extension
  version "0.9.2"  # Compatible with Radiant 0.9
  description "Adds a calendar of events to your Radiant site."
  url "http://github.com/davec/radiant-events-calendar-extension"
  
  def activate
    tab "Content" do
      add_item "Events", "/admin/events", :after => "Pages"
    end
    Page.send :include, EventsCalendarTags
  end
  
end
