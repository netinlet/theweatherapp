require "rails_helper"

module TestAlternateProvider
  class FakeWeather
  end
end

RSpec.describe WeatherService, type: :services do
  context "it can swap weather providers" do
    before do
      @original_provider = WeatherService.weather_provider
    end

    after do
      WeatherService.weather_provider = @original_provider
    end

    it "can swap to an alternate provider with a class" do
      WeatherService.weather_provider = TestAlternateProvider::FakeWeather
      expect(WeatherService.weather_provider).to be_instance_of(TestAlternateProvider::FakeWeather)
    end

    it "can swap to an alternate provider with an instance" do
      WeatherService.weather_provider = TestAlternateProvider::FakeWeather.new
      expect(WeatherService.weather_provider).to be_instance_of(TestAlternateProvider::FakeWeather)
    end
  end
end
