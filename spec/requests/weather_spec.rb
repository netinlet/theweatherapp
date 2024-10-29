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
    end
  end
end
