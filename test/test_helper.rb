# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rails/railtie"

require "active_record"
require "active_job"

require "active_operator"

require "debug"
require "minitest/autorun"

ActiveOperator::Railtie.run_initializers

GlobalID.app = "active-operator"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["VERBOSE"] || ENV["CI"]
ActiveJob::Base.logger = nil unless ENV["VERBOSE"] || ENV["CI"]

ActiveRecord::Schema.define do
  create_table :active_operator_operations do |t|
    t.string :type, null: false
    t.references :record, polymorphic: true, null: false, index: true
    t.json :response, null: false, default: "{}"
    t.datetime :received_at
    t.datetime :processed_at
    t.datetime :errored_at

    t.timestamps
  end

  create_table :locations do |t|
    t.string :street
    t.string :city
    t.string :state
    t.string :zip
    t.string :country
    t.string :timezone
    t.decimal :latitude, precision: 15, scale: 10
    t.decimal :longitude, precision: 15, scale: 10

    t.timestamps
  end
end

class ApplicationRecord < ActiveRecord::Base
  include GlobalID::Identification

  self.abstract_class = true
end

class Location < ApplicationRecord
  has_operation :address_verification
  has_operation :geocoding, class_name: "Geocoding::V2"

  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true

  def address
    [street, city, state, zip, country].compact_blank.join(", ")
  end
end

class ApplicationOperation < ActiveOperator::Operation
  include GlobalID::Identification

  self.abstract_class = true
end

class AddressVerification < ApplicationOperation; end

module Geocoding; end
class Geocoding::V1 < ApplicationOperation; end
class Geocoding::V2 < ApplicationOperation; end

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  private

  def create_location
    Location.create!(
      street: "123 Main St.",
      city: "Anytown",
      state: "NJ",
      zip: "12345",
      country: "US"
    )
  end

  def with_operation_methods(operation_class, methods_module)
    begin
      operation_class.class_eval do
        define_method :request, methods_module.instance_method(:request)
        define_method :process, methods_module.instance_method(:process)
      end

      yield
    ensure
      operation_class.class_eval do
        remove_method :request if method_defined?(:request)
        remove_method :process if method_defined?(:process)
      end
    end
  end

  module GeocodingValid
    def request
      {
        "status" => 200,
        "body" => {
          "results" => [
            {
              "formatted_address" => "123 Main St., Anytown, NJ 12345",
              "location" => {"lat" => 40.59806, "lng" => -74.68148},
              "accuracy" => 1,
              "fields" => {
                "timezone" => {
                  "name" => "America/New_York",
                  "utc_offset" => -5,
                  "observes_dst" => true,
                  "abbreviation" => "EST"
                }
              }
            }
          ]
        },
        "response_headers" => {
          "content-type" => "application/json",
        }
      }
    end

    def process
      result = response.dig("body", "results", 0)

      record.update!(
        latitude: result.dig("location", "lat"),
        longitude: result.dig("location", "lng"),
        timezone: result.dig("fields", "timezone", "name")
      )
    end
  end

  module GeocodingInvalidRequest
    def request
      {
        "status" => 200,
        "body" => {
          "results" => []
        },
        "response_headers" => {
          "content-type" => "application/json",
        }
      }
    end

    def process
      result = response.dig("body", "results", 0)

      record.update!(
        latitude: result.dig("location", "lat"),
        longitude: result.dig("location", "lng"),
        timezone: result.dig("fields", "timezone", "name")
      )
    end
  end

  module GeocodingFailedRequest
    class RequestError < StandardError; end

    def request
      raise RequestError, "API request failed"
    end

    def process
      result = response.dig("body", "results", 0)

      record.update!(
        latitude: result.dig("location", "lat"),
        longitude: result.dig("location", "lng"),
        timezone: result.dig("fields", "timezone", "name")
      )
    end
  end

  module GeocodingFailedProcess
    def request
      {}
    end

    def process
      # Fails validation
      record.update!(street: nil)
    end
  end
end
