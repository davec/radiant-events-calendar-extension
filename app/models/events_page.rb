class EventsPage < Page
  include Radiant::Taggable

  attr_accessor :date

  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    if url =~ %r{^#{self.url}(\d{4})/((0?[1-9])|(1[0-2]))/((0?[1-9])|([12]\d)|(3[01]))/?$}
      begin
        self.date = Date.civil($1.to_i, $2.to_i, $5.to_i)
        self.title = "Events for #{self.date.to_s(:long)}"
        self
      rescue ArgumentError => e
        super
      end
    else
      super
    end
  end

  def virtual?
    true
  end

  tag "events" do |tag|
    tag.locals.events = Event.for_date(self.date)
    tag.expand
  end

end
