# frozen_string_literal: true

require "rails/generators/active_record"

module ActiveOperator
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def copy_migration_file
        migration_template(
          "create_active_operator_operations.rb.erb",
          "db/migrate/create_active_operator_operations.rb"
        )
      end

      def create_application_operation
        template(
          "application_operation.rb.erb",
          "app/operations/application_operation.rb"
        )
      end
    end
  end
end
