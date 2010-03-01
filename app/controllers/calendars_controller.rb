class CalendarsController < ApplicationController
  include CalendarsHelper

  no_login_required

  def show
    respond_to do |format|
      format.js {
        @calendar = make_calendar(Date.civil(params[:year].to_i, params[:month].to_i), true) rescue nil
      }
      format.html {
        session[:calendar_view] = { :year => params[:year], :month => params[:month] }
        redirect_to(:back)
      }
    end
  end

end
