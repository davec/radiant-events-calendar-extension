class Admin::EventsController < Admin::ResourceController
  if defined?(TextileEditorExtension)
    before_filter :include_textile_editor_assets, :only => [:new, :edit]
  end
  before_filter :adjust_times, :only => [ :create, :update ]
  model_class Event

  helper 'admin/references'

  def auto_complete_for_event_category
    find_options = {
      :select => "DISTINCT category",
      :conditions => [ "LOWER(category) LIKE ?", "#{params[:event][:category].downcase}%" ],
      :order => "category ASC",
      :limit => 10 }
    @items = Event.send(:with_exclusive_scope) { Event.all(find_options) }
    render :inline => "<%= auto_complete_result @items, 'category' %>"
  end

  def copy
    @event = Event.find(params[:id]).clone
    render :new
  rescue
    flash[:notice] = "Error copying event"
    redirect_to admin_events_url
  end

  protected

    def load_models
      # Order the events by date, and exclude any in the past
      self.models = model_class.all(:order => 'date, start_time, name',
                                    :conditions => [ 'date >= ?', Date.today ])
    end

    def adjust_times
      start_time = parse_time(params[:event].delete('start_time(5i)'))
      end_time = parse_time(params[:event].delete('end_time(5i)'))

      date = Date.parse(params[:event][:date])
      params[:event][:start_time] = start_time.is_a?(Time) ?
        start_time.change(:year => date.year, :month => date.month, :day => date.day) :
        start_time
      params[:event][:end_time] = end_time.is_a?(Time) ?
        end_time.change(:year => date.year, :month => date.month, :day => date.day).advance(:days => start_time.is_a?(Time) && end_time < start_time ? 1 : 0) :
        end_time
    end

  private

    def parse_time(str)
      str.blank? ? str : Time.parse(str)
    end

end
