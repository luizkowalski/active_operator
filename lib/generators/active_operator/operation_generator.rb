require 'rails/generators'
require 'active_support/inflector'

module ActiveOperator
  module Generators
    class OperationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      check_class_collision suffix: "Operation"

      source_root File.expand_path("templates", __dir__)

      desc "Generates an operation with the given NAME."

      def create_operation_file
        template "operation.rb.erb", "app/operations/#{operation_file_path}_operation.rb"
      end

      private

      def file_name
        @_file_name ||= super.sub(/_operation\z/i, "")
      end

      def operation_file_path
        name.underscore.sub(/_operation\z/i, "")
      end

    end
  end
end
