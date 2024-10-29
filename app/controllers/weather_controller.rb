class WeatherController < ApplicationController
  def index
    @address = params[:address] || "1 Apple Park Way. Cupertino, CA 95014"
    postal_code = @address.match(/\d{5}/)&.to_a&.last
    logger.info "postal_code: #{postal_code}"
    @cache_hit = false
    @weather = {}

    begin
      logger.info "Checking cache for #{postal_code}"
      if (@weather = Rails.cache.fetch(postal_code))
        logger.info "Cache hit for #{postal_code}"
        @cache_hit = true
      else
        logger.info "Cache miss for #{postal_code}"
        @weather = WeatherService.get_current_weather(postal_code)
        Rails.cache.write(postal_code, @weather, expires_in: 30.minutes, skip_nil: true)
      end
    rescue => e
      logger.error "Error fetching weather data: #{e.message}"
      flash[:error] = "Error fetching weather data: #{e.message}"
      @weather = {}
    end

    if @weather.empty?
      flash[:error] = "Please ensure the address is valid and includes a valid postal code"
    end

    render :index
  end
end
