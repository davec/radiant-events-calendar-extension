ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :member => { :remove => :get, :copy => :get } do |admin|
    admin.resources :events, :collection => { :auto_complete_for_event_category => :get }
  end
  map.calendar '/calendar/:year/:month',  :controller => 'calendars',
                                          :action => 'show',
                                          :year => /20\d\d/,
                                          :month => /(0?[1-9])|(1[0-2])/,
                                          :conditions => { :method => :get }
end
