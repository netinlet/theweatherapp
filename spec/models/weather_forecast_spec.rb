require "rails_helper"

RSpec.describe WeatherForecast, type: :model do
  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:temperature_max) }
    it { should validate_presence_of(:temperature_min) }
    it { should validate_presence_of(:precipitation_probability) }
  end
end
