class WeatherController < ApplicationController
  def index
    @address = params[:address]
    postal_code = WeatherService.extract_postal_code(@address)

    # if both are blank, we have no input
    if postal_code.blank? && @address.blank?
      render :index
      return
    elsif postal_code.blank?
      # we had input but it's not a valid postal code
      flash[:error] = "Please ensure the address is valid and includes a valid postal code"
      render :index
      return
    end

    logger.info "postal_code: #{postal_code}"
    @cache_hit = false
    @weather = nil

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
      @weather = nil
    end

    render :index
  end
end
