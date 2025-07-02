# frozen_string_literal: true

require "test_helper"

require "rails/generators"
require "generators/active_operator/install_generator"

module ActiveOperator
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests ActiveOperator::Generators::InstallGenerator

      destination File.expand_path("../../tmp", __dir__)
      setup :prepare_destination

      def after_teardown
        FileUtils.rm_rf destination_root
        super
      end

      test "should generate migration file and application_operator file" do
        run_generator

        assert_migration "db/migrate/create_active_operator_operations.rb"
        migration_contents = File.read(migration_file_name("db/migrate/create_active_operator_operations"))
        assert_match "create_table :active_operator_operations", migration_contents

        assert_file "app/operations/application_operation.rb"
      end
    end
  end
end
