class Weather
  include ActiveModel::API

  attr_accessor :postal_code, :latitude, :longitude, :current_temperature, :temperature_unit, :current_precipitation

  def forecast
    @forecast ||= []
  end

  def forecast=(value)
    @forecast = Array(value)
  end

  validates :postal_code, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :current_temperature, presence: true
  validates :temperature_unit, presence: true
  validates :current_precipitation, presence: true
  validates :forecast, presence: true

  validate :forecasts_are_valid

  def self.get_current_weather(postal_code)
    service_weather = WeatherService.get_current_weather(postal_code)
    service_forecast = service_weather.delete(:forecast)
    daily_forecast = service_forecast.map do |forecast_day|
      WeatherForecast.new(forecast_day)
    end

    weather = new(service_weather)
    weather.forecast = daily_forecast

    weather
  end

  private

  def forecasts_are_valid
    forecast.each do |forecast|
      unless forecast.valid?
        errors.add(:forecast, "contains invalid forecast")
      end
    end
  end
end
