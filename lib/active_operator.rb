# frozen_string_literal: true

require "active_operator/version"
require "active_operator/model"
require "active_operator/operation"
require "active_operator/perform_operation_job"

module ActiveOperator
  def self.table_name_prefix
    "active_operator_"
  end
end

require "active_operator/railtie" if defined?(Rails::Railtie)
