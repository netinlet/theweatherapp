require "rails_helper"

RSpec.describe Weather, type: :model do
  describe "validations" do
    it { should validate_presence_of(:postal_code) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_presence_of(:current_temperature) }
    it { should validate_presence_of(:temperature_unit) }
    it { should validate_presence_of(:current_precipitation) }
    it { should validate_presence_of(:forecast) }

    let(:valid_forecast) { (0..3).map { |n| WeatherForecast.new(date: n.days.from_now.iso8601, temperature_max: 85, temperature_min: 73, precipitation_probability: 0) } }
    let(:invalid_forecast) { [WeatherForecast.new(date: Date.today.iso8601, temperature_max: nil, temperature_min: 73, precipitation_probability: 0)] }

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
end
