class WeatherForecast
  include ActiveModel::API

  attr_accessor :date, :temperature_max, :temperature_min, :precipitation_probability

  validates :date, presence: true
  validates :temperature_max, presence: true
  validates :temperature_min, presence: true
  validates :precipitation_probability, presence: true
end
