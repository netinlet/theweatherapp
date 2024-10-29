require "rails_helper"

RSpec.describe WeatherService::OpenMateo, type: :services do
  let(:subject) { WeatherService::OpenMateo.new }

  describe "get_geo_by_postal_code" do
    context "success" do
      it "can query geo coordinates by postal code" do
        expect(subject.get_geo_by_postal_code("90210")).to eq({latitude: 34.07362, longitude: -118.40036})
      end
    end

    context "failure" do
      it "raises an error if no results are found" do
        expect { subject.get_geo_by_postal_code("99999") }.to raise_error("No results found for postal code 99999")
      end
    end
  end

  describe "get_current_weather" do
    context "success" do
      it "can query current weather by geo coordinates" do
        current_weather = subject.get_current_weather_by_lat_lon(34.07362, -118.40036)
        expect(current_weather[:latitude]).to eq(34.07362)
        expect(current_weather[:longitude]).to eq(-118.40036)
        expect(current_weather[:current_temperature]).to be_a(Numeric)
        expect(current_weather[:temperature_unit]).to eq("°F")
        expect(current_weather[:current_precipitation]).to be_a(Numeric)
        expect(current_weather[:forecast].length).to eq(7)
        expect(current_weather[:forecast].first.keys).to eq([:date, :temperature_max, :temperature_min, :precipitation_probability])
        expect(current_weather[:forecast].first.values.first).to match(/\d{4}-\d{2}-\d{2}/) # first is date in YYYY-MM-DD format
        expect(current_weather[:forecast].first.values[-1]).to be_a(Numeric) # temperature_value
        expect(current_weather[:forecast].first.values[-2]).to be_a(Numeric) # temperature_value
      end
    end

    context "failure" do
      it "raises an error if the API returns an error" do
        expect { subject.get_current_weather_by_lat_lon(99999, 99999) }.to raise_error("Error fetching weather data: Latitude must be in range of -90 to 90°. Given: 99999.0.")
      end
    end
  end

  describe "protected - make_request" do
    it "raises an error if the API returns an error" do
      expect { subject.send(:make_request, URI("http://example.com/api/error")) }.to raise_error("Error making request to http://example.com/api/error: unexpected token at '<!doctype html>\n<html>\n<head>\n  '")
    end
  end
end
