class Weather
  include ActiveModel::API
  include ModelLogger

  attr_accessor :postal_code, :latitude, :longitude, :current_temperature, :temperature_unit, :current_precipitation, :cache_hit

  def self.load(payload)
    data = JSON.parse(payload, symbolize_names: true)
    data[:forecast] = data[:forecast].map { |f| WeatherForecast.load(f) }
    new(data)
  end

  def self.dump(weather)
    JSON.dump(weather.to_h)
  end

  def initialize(attributes = {})
    super
    @cache_hit = attributes[:cache_hit] || false
  end

  def to_h
    {
      postal_code: postal_code,
      latitude: latitude,
      longitude: longitude,
      current_temperature: current_temperature,
      temperature_unit: temperature_unit,
      current_precipitation: current_precipitation,
      forecast: forecast.map(&:to_h)
    }
  end

  def forecast
    @forecast ||= []
  end

  def forecast=(value)
    @forecast = Array(value)
  end

  alias_method :cache_hit?, :cache_hit

  validates :postal_code, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :current_temperature, presence: true
  validates :temperature_unit, presence: true
  validates :current_precipitation, presence: true
  validates :forecast, presence: true

  validate :forecasts_are_valid

  def self.get_current_weather(address)
    postal_code = WeatherService.extract_postal_code(address)
    weather = nil
    begin
      logger.info "Checking cache for #{postal_code}"
      if (weather_data = Rails.cache.fetch(postal_code))
        weather = load(weather_data)
        weather.cache_hit = true
        logger.info "Cache hit for #{postal_code}"
      else
        logger.info "Cache miss for #{postal_code}"
        service_weather = WeatherService.get_current_weather(postal_code)
        service_forecast = service_weather.delete(:forecast)
        daily_forecast = service_forecast.map do |forecast_day|
          WeatherForecast.new(forecast_day)
        end

        weather = new(service_weather)
        weather.forecast = daily_forecast

        Rails.cache.write(postal_code, dump(weather), expires_in: 30.minutes, skip_nil: true)
      end
    rescue => e
      logger.error "Error fetching weather data: #{e.message}"
      weather = new(postal_code: postal_code)
      weather
    end
    weather
  end

  private

  def forecasts_are_valid
    forecast.each do |forecast|
      logger.info "forecast: #{forecast.inspect}"
      unless forecast.valid?
        errors.add(:forecast, "contains invalid forecast")
      end
    end
  end
end
