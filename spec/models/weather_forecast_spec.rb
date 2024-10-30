require "rails_helper"

RSpec.describe WeatherForecast, type: :model do
  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:temperature_max) }
    it { should validate_presence_of(:temperature_min) }
    it { should validate_presence_of(:precipitation_probability) }
  end

  let(:subject) { described_class.new(date: Date.today, temperature_max: 70, temperature_min: 50, precipitation_probability: 30) }

  describe "#to_h" do
    it "returns a hash of the attributes" do
      expect(subject.to_h).to eq({
        date: subject.date.iso8601,
        temperature_max: subject.temperature_max,
        temperature_min: subject.temperature_min,
        precipitation_probability: subject.precipitation_probability
      })
    end
  end

  describe "serialization" do
    it "serializes to JSON" do
      expect(JSON.parse(described_class.dump(subject))).to eq(subject.to_h.stringify_keys)
    end

    it "deserializes from JSON" do
      weather_forecast = described_class.load(described_class.dump(subject))
      expect(weather_forecast.to_h).to eq(subject.to_h)
    end
  end
end
