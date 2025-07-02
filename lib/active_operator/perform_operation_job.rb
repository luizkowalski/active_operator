# frozen_string_literal: true

module ActiveOperator
  class PerformOperationJob < ActiveJob::Base
    discard_on ActiveRecord::RecordNotFound

    def perform(operation)
      operation.perform
    end
  end
end
