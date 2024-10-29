module WeatherService
  extend self

  def weather_provider=(provider)
    # if a class is provided, instantiate it
    @weather_provider = if provider.is_a?(Class)
      provider.new
    else
      provider
    end
  end

  def weather_provider
    # provide a default implementation if not specified
    @weather_provider ||= ::WeatherService::OpenMateo.new
  end

  def extract_postal_code(address)
    address&.match(/(?<!\d)\d{5}(?!\d)/)&.to_a&.last
  end

  def get_current_weather(postal_code)
    weather_provider.get_current_weather(postal_code)
  end
end
