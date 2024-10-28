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
end
