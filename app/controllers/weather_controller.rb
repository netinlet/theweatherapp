class WeatherController < ApplicationController
  def index
    @address = params[:address]

    # no input
    if @address.blank?
      render :index
      return
    end

    @weather = Weather.get_current_weather(@address)

    if !@weather.valid?
      flash[:error] = "Please ensure the address is valid and includes a valid postal code"
      render :index
      return
    end

    render :index
  end
end
