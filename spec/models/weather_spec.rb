require "rails_helper"

RSpec.describe Weather, type: :model do
  let(:valid_forecast) { (0..3).map { |n| WeatherForecast.new(date: n.days.from_now.to_date.iso8601, temperature_max: 85, temperature_min: 73, precipitation_probability: 0) } }

  describe "validations" do
    it { should validate_presence_of(:postal_code) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_presence_of(:current_temperature) }
    it { should validate_presence_of(:temperature_unit) }
    it { should validate_presence_of(:current_precipitation) }
    it { should validate_presence_of(:forecast) }

    let(:invalid_forecast) { [WeatherForecast.new(date: Date.today.to_date.iso8601, temperature_max: nil, temperature_min: 73, precipitation_probability: 0)] }

    it "validates that the forecast is valid" do
      weather = described_class.new(postal_code: "12345", latitude: 37.7749, longitude: -122.4194, current_temperature: 75, temperature_unit: "F", current_precipitation: 0, forecast: valid_forecast)
      expect(weather).to be_valid
    end

    it "is invalid when the weather forecast contains an invalid forecast" do
      weather = described_class.new(postal_code: "12345", latitude: 37.7749, longitude: -122.4194, current_temperature: 75, temperature_unit: "F", current_precipitation: 0, forecast: valid_forecast + invalid_forecast)
      expect(weather).to be_invalid
    end
  end

  describe ".get_current_weather" do
    it "returns a weather object with a valid forecast" do
      weather = described_class.get_current_weather("74119")
      expect(weather).to be_valid
    end
  end

  describe "#to_h" do
    let(:subject) {
      described_class.new(postal_code: "12345", latitude: 37.7749, longitude: -122.4194,
        current_temperature: 75, temperature_unit: "F", current_precipitation: 0, forecast: valid_forecast)
    }

    it "returns a hash of the attributes" do
      expect(subject.to_h).to eq({
        postal_code: subject.postal_code,
        latitude: subject.latitude,
        longitude: subject.longitude,
        current_temperature: subject.current_temperature,
        temperature_unit: subject.temperature_unit,
        current_precipitation: subject.current_precipitation,
        forecast: subject.forecast.map(&:to_h)
      })
    end
  end

  describe "serialization" do
    let(:subject) { described_class.new(postal_code: "12345", latitude: 37.7749, longitude: -122.4194, current_temperature: 75, temperature_unit: "F", current_precipitation: 0, forecast: valid_forecast) }

    it "serializes to JSON" do
      expect(JSON.parse(described_class.dump(subject))).to eq(subject.to_h.deep_stringify_keys)
    end

    it "deserializes from JSON" do
      weather = described_class.load(described_class.dump(subject))
      expect(weather.to_h).to eq({
        postal_code: subject.postal_code,
        latitude: subject.latitude,
        longitude: subject.longitude,
        current_temperature: subject.current_temperature,
        temperature_unit: subject.temperature_unit,
        current_precipitation: subject.current_precipitation,
        forecast: subject.forecast.map { |f| f.to_h.symbolize_keys }
      })
    end
  end

  describe "Caching weather data" do
    it "caches the weather data" do
      Rails.cache.clear
      # no cached values...
      expect(Rails.cache.exist?("95014")).to be_falsey

      weather = described_class.get_current_weather("1 Apple Park Way. Cupertino, CA 95014")
      expect(Rails.cache.exist?("95014")).to be_truthy # we now have the weather data cached
      expect(weather.cache_hit).to be_falsey # we rendered w/ a cache miss - show that

      # now we'll make sure it's cached
      weather = described_class.get_current_weather("1 Apple Park Way. Cupertino, CA 95014")
      expect(Rails.cache.exist?("95014")).to be_truthy
      expect(weather.cache_hit).to be_truthy
    end
  end
end
