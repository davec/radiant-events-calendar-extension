class AddEventsPage < ActiveRecord::Migration
  def self.up
    unless Page.find_by_slug("events")
      page = EventsPage.new(:slug => "events", :title => "Events", :breadcrumb => "Events", :status => Status[:published], :parent => Page.find_by_slug("/"))
      page_parts = YAML.load_file(File.join(File.dirname(__FILE__), "..", "templates", "events_page_parts.yml"))
      page.parts << PagePart.new(page_parts["body"])
      page.save!
    end
  end

  def self.down
  end
end
