require "rails_helper"

RSpec.describe WeatherForecast, type: :model do
  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:temperature_max) }
    it { should validate_presence_of(:temperature_min) }
    it { should validate_presence_of(:precipitation_probability) }
  end

  describe "#to_h" do
    it "returns a hash of the attributes" do
      expect(subject.to_h).to eq({
        date: subject.date,
        temperature_max: subject.temperature_max,
        temperature_min: subject.temperature_min,
        precipitation_probability: subject.precipitation_probability
      })
    end
  end
end
