# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class EventsCalendarExtension < Radiant::Extension
  version "0.5"
  description "Adds a calendar of events to your Radiant site."
  url "http://github.com/davec/radiant-events-calendar-extension"
  
  def activate
    admin.tabs.add "Events", "/admin/events", :after => "Layouts"
    Page.send :include, EventsCalendarTags
  end
  
  def deactivate
  end
  
end
