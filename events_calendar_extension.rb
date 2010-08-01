# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class EventsCalendarExtension < Radiant::Extension
  version "0.8"
  description "Adds a calendar of events to your Radiant site."
  url "http://github.com/davec/radiant-events-calendar-extension"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get, :copy => :get } do |admin|
      admin.resources :events, :collection => { :auto_complete_for_event_category => :get }
    end
    map.calendar '/calendar/:year/:month',  :controller => 'calendars',
                                            :action => 'show',
                                            :year => /20\d\d/,
                                            :month => /(0?[1-9])|(1[0-2])/,
                                            :conditions => { :method => :get }
  end
  
  def activate
    admin.tabs.add "Events", "/admin/events", :after => "Layouts"
    Page.send :include, EventsCalendarTags
  end
  
  def deactivate
  end
  
end
