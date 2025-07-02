# frozen_string_literal: true

module ActiveOperator
  class Railtie < Rails::Railtie
    initializer "active_operator.include_model" do
      ActiveSupport.on_load(:active_record) do
        include ActiveOperator::Model
      end
    end
  end
end
