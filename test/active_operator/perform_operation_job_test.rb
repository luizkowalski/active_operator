# frozen_string_literal: true

require "test_helper"

module ActiveOperator
  class PerformOperationJobTest < ActiveSupport::TestCase
    test "#perform" do
      location = create_location
      location.geocoding.save!

      with_operation_methods(Geocoding::V2, GeocodingValid) do
        assert_nil location.latitude
        assert_nil location.longitude
        assert_nil location.timezone
        assert_nil location.geocoding.received_at
        assert_nil location.geocoding.processed_at

        ActiveOperator::PerformOperationJob.new.perform(location.geocoding)

        assert_equal 40.59806, location.latitude
        assert_equal -74.68148, location.longitude
        assert_equal "America/New_York", location.timezone
        assert_not_nil location.geocoding.received_at
        assert_not_nil location.geocoding.processed_at
      end
    end
  end
end
