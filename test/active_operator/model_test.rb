# frozen_string_literal: true

require "test_helper"

module ActiveOperator
  class ModelTest < ActiveSupport::TestCase
    test "has_operation associations" do
      location = create_location

      assert location.address_verification.new_record?
      assert location.geocoding.new_record?

      assert_equal location, location.address_verification.record
      assert_equal location, location.geocoding.record

      location.address_verification.save!
      location.geocoding.save!

      assert location.address_verification.persisted?
      assert location.geocoding.persisted?

      assert_equal AddressVerification, location.address_verification.class
      assert_equal Geocoding::V2, location.geocoding.class
    end
  end
end
