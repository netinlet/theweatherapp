# The Weather App

## Overview

A Rails 7 application that provides current temperature and 7-day weather forecasts based on user-provided locations.

Users can enter an address in any of these formats:
* Full address (e.g., 123 Main Street, Somewhere, SomeState, 90210)
* City, State & Postal code (e.g., Beverly Hills, CA 90210)
* US postal code only (e.g., 90210)

Note: All queries require a valid US postal code.

## Project Requirements

* Built with Ruby on Rails
* Address input functionality
* Weather forecast retrieval including current temperature (with optional high/low and extended forecast)
* Forecast display interface
* 30-minute forecast caching by zip code with cache indicator

Assumptions:
* Functionality prioritized over aesthetics
* Open to implementation interpretation

## Technical Implementation

* Uses OpenMeteo API (https://open-meteo.com/) for weather data
* Weather API interactions handled by `services/weather_service.rb`
* Modular design of `WeatherService` allows for alternative weather provider implementation via accessor `weather_provider`.
* Models (`Weather` and `WeatherForecast`) provide Rails-standard interface and handle caching API requests

### Caching

Since this is a demo project, caching is handled via Rails built-in caching using `:memory_store`

All requests are cached for `30 minutes` by postal code per requirements.

In a production environment, I would use either `redis` or `memcache` as the backing store, depending on the best fit for the company and stack. The `:memory_store` is not scalable in a production environment, only for dev/test purposes.


## System Requirements

* Ruby 3.3.4

## Setup Instructions

1. Clone the repository
2. Install dependencies:
```
bundle install
```

## Test Instructions

```
rails spec
# - or -
bundle exec rspec
```

Note: code coverage is generated into the `coverage` directory at `coverage/index.html`

### Dependencies

Production:
* tailwindcss-rails

Development & Testing:
* rspec-rails
* shoulda-matchers
* simplecov

## Running Locally

Start the development server:
```
./bin/dev
```

Access the application at http://localhost:3000