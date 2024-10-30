require "rails_helper"

RSpec.describe "Weather", type: :request do
  describe "GET /index" do
    it "returns http success with no params" do
      get weather_index_path
      expect(response).to have_http_status(:success)
    end

    it "errors with an invalid postal code" do
      get weather_index_path(address: "99999")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Error fetching weather data: No results found for postal code 99999")
    end

    it "errors without a postal code" do
      get weather_index_path(address: "123 Main St. Anytown, USA")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Please ensure the address is valid and includes a valid postal code")
    end
  end
end
