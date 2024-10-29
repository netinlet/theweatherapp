class WeatherController < ApplicationController
  def index
    @address = params[:address] || "1 Apple Park Way. Cupertino, CA 95014"
    postal_code = @address.match(/\d{5}/)&.to_a&.last
    logger.info "postal_code: #{postal_code}"

    begin
      @weather = WeatherService.get_current_weather(postal_code)
    rescue => e
      logger.error "Error fetching weather data: #{e.message}"
      flash[:error] = "Error fetching weather data: #{e.message}"
      @weather = {}
    end

    if @weather.empty?
      flash[:error] = "Please ensure the address is valid and in the following format: 1234 Main St. City, ST 12345"
    end

    render :index
  end
end
