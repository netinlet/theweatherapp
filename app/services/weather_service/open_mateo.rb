require "net/http"

module WeatherService
  class OpenMateo
    def initialize(timeout: 5)
      @timeout = timeout * 1000
    end

    def get_geo_by_postal_code(postal_code)
      uri = URI("https://geocoding-api.open-meteo.com/v1/search?name=#{postal_code}&count=1&language=en&format=json")
      result = make_request(uri)
      if result["results"]&.any?
        {
          latitude: result["results"].first["latitude"],
          longitude: result["results"].first["longitude"]
        }
      else
        raise "No results found for postal code #{postal_code}"
      end
    end

    def get_current_weather(latitude, longitude)
      uri = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch")
      weather_data = make_request(uri)

      if weather_data["error"]
        raise "Error fetching weather data: #{weather_data["reason"]}"
      end

      # return the current temperature, unit of measurement, and the forecast for the next 7 days
      {
        latitude: latitude,
        longitude: longitude,
        current_temperature: weather_data["current"]["temperature_2m"],
        current_unit: weather_data["current_units"]["temperature_2m"],
        forecast: weather_data["daily"]["time"].map.with_index do |date, index|
          {
            date: date,
            temperature_max: weather_data["daily"]["temperature_2m_max"][index],
            temperature_min: weather_data["daily"]["temperature_2m_min"][index]
          }
        end
      }
    end

    protected

    def make_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = @timeout
      full_path = uri.path
      if uri.query
        full_path += "?" + uri.query
      end
      response = http.get(full_path)
      JSON.parse(response.body)
    rescue => e
      raise "Error making request to #{uri}: #{e.message}"
    end
  end
end
