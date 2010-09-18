class CalendarsController < ApplicationController
  include CalendarsHelper

  no_login_required

  def show
    respond_to do |format|
      format.js {
        if calendar = make_calendar(Date.civil(params[:year].to_i, params[:month].to_i), true) rescue nil
          response.headers['Content-Type'] = 'text/html'
          render :text => calendar and return
        end
        render :text => 'Calendar FAIL', :status => 500
      }
      format.html {
        session[:calendar_view] = { :year => params[:year], :month => params[:month] }
        redirect_to(:back)
      }
    end
  end

end
