# frozen_string_literal: true

module ActiveOperator
  class Operation < ActiveRecord::Base
    self.table_name = "active_operator_operations"

    belongs_to :record, polymorphic: true

    def received?  = received_at?
    def processed? = processed_at?
    def errored?   = errored_at?

    def perform
      request!
      process!
    rescue
      errored!
      raise
    end

    def perform_later
      ActiveOperator::PerformOperationJob.perform_later(self)
    end

    def request!
      return false if received?

      update!(response: request, received_at: Time.current)
    end

    def process!
      return false if !received?
      return false if processed?

      ActiveRecord::Base.transaction do
        process
        update!(processed_at: Time.current)
      end
    end

    def errored!
      update!(errored_at: Time.current)
    end

    def request
      raise NotImplementedError, "Operations must implement the `request` method"
    end

    def process
      raise NotImplementedError, "Operations must implement the `process` method"
    end
  end
end
