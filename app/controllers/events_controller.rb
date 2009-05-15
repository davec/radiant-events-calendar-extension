class EventsController < ApplicationController
  radiant_layout 'Normal'
  no_login_required

  def show
    @date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @events = Event.for_date(@date) if @date
  end

end
