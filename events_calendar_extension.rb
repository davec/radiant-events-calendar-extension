# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class EventsCalendarExtension < Radiant::Extension
  version "0.5.1"
  description "Adds a calendar of events to your Radiant site."
  url "http://github.com/davec/radiant-events-calendar-extension"
  
  def activate
    tab "Content" do
      add_item "Events", "/admin/events", :after => "Pages"
    end
    Page.send :include, EventsCalendarTags
  end
  
end
