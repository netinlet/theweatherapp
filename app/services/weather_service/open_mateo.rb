require "net/http"

module WeatherService
  class OpenMateo
    attr_reader :logger
    def initialize(timeout: 5)
      @timeout = timeout * 1000
      @logger = Rails.logger
    end

    def get_geo_by_postal_code(postal_code)
      uri = URI("https://geocoding-api.open-meteo.com/v1/search?name=#{postal_code}&count=1&language=en&format=json")
      result = make_request(uri)
      logger.info("GEO result: #{result}")
      if result["results"]&.any?
        {
          latitude: result["results"].first["latitude"],
          longitude: result["results"].first["longitude"]
        }
      else
        raise "No results found for postal code #{postal_code}"
      end
    end

    def get_current_weather_by_lat_lon(latitude, longitude)
      uri = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch")
      weather_data = make_request(uri)
      logger.info(weather_data)
      if weather_data["error"]
        raise "Error fetching weather data: #{weather_data["reason"]}"
      end

      # return the current temperature, unit of measurement, and the forecast for the next 7 days
      {
        latitude: latitude,
        longitude: longitude,
        current_temperature: weather_data["current"]["temperature_2m"],
        temperature_unit: weather_data["current_units"]["temperature_2m"],
        current_precipitation: weather_data["current"]["precipitation"],
        forecast: weather_data["daily"]["time"].map.with_index do |date, index|
          {
            date: date,
            temperature_max: weather_data["daily"]["temperature_2m_max"][index],
            temperature_min: weather_data["daily"]["temperature_2m_min"][index],
            precipitation_probability: weather_data["daily"]["precipitation_probability_max"][index]
          }
        end
      }
    end

    def get_current_weather(postal_code)
      geo_data = get_geo_by_postal_code(postal_code)
      weather_data = get_current_weather_by_lat_lon(geo_data[:latitude], geo_data[:longitude])
      weather_data[:postal_code] = postal_code
      weather_data
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
