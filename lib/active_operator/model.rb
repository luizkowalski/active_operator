# frozen_string_literal: true

module ActiveOperator
  module Model
    extend ActiveSupport::Concern

    class_methods do
      def has_operation(name, class_name: name.to_s.classify)
        has_one name, class_name:, as: :record, inverse_of: :record, dependent: :destroy
        define_method(name) { super() || public_send("build_#{name}") }
      end
    end
  end
end
