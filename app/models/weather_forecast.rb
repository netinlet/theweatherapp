class WeatherForecast
  include ActiveModel::API

  attr_accessor :date, :temperature_max, :temperature_min, :precipitation_probability

  validates :date, presence: true
  validates :temperature_max, presence: true
  validates :temperature_min, presence: true
  validates :precipitation_probability, presence: true

  def self.dump(weather)
    JSON.dump(weather.to_h)
  end

  def self.load(payload)
    # handle case of raw json or loading from weather object where data is already a hash
    data = if payload.is_a?(String)
      JSON.parse(payload, symbolize_names: true)
    else
      payload
    end
    data[:date] = Date.parse(data[:date])
    new(data)
  end

  def initialize(attributes = {})
    super
    if attributes[:date].is_a?(String)
      @date = Date.parse(attributes[:date])
    end
  end

  def to_h
    {
      date: date.iso8601,
      temperature_max: temperature_max,
      temperature_min: temperature_min,
      precipitation_probability: precipitation_probability
    }
  end
end
