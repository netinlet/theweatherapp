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

  it "can extract a postal code from an address" do
  end

  context "extract postal code" do
    specify { expect(WeatherService.extract_postal_code("1 Apple Park Way. Cupertino, CA 95014")).to eq("95014") }
    specify { expect(WeatherService.extract_postal_code("123 Main St. Anytown, USA 12345")).to eq("12345") }
    specify { expect(WeatherService.extract_postal_code("90210")).to eq("90210") }
    specify { expect(WeatherService.extract_postal_code("90210-1234")).to eq("90210") }
    specify { expect(WeatherService.extract_postal_code("Tulsa, OK 74119")).to eq("74119") }

    # no postal code extracted
    specify { expect(WeatherService.extract_postal_code("123 Main St. Anytown, USA")).to be_nil }
    specify { expect(WeatherService.extract_postal_code("902101234")).to be_nil }
  end

  it "can get current weather" do
    expect(WeatherService.get_current_weather("95014")).to be_a(Hash)
  end
end
