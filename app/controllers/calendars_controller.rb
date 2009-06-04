class CalendarsController < ApplicationController
  include CalendarsHelper

  no_login_required

  def show
    if request.xhr?
      @calendar = make_calendar(Date.civil(params[:year].to_i, params[:month].to_i), true) rescue nil
    end
  end

end
