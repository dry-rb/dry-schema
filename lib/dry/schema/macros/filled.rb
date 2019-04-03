# frozen_string_literal: true

require 'dry/schema/macros/value'

module Dry
  module Schema
    module Macros
      # Macro used to prepend `:filled?` predicate
      #
      # @api public
      class Filled < Value
        def call(*predicates, **opts, &block)
          if predicates.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with empty? predicate is invalid'
          end

          if predicates.include?(:filled?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with filled? is redundant'
          end

          if opts[:type_spec]
            value(predicates[0], :filled?, *predicates[1..predicates.size - 1], **opts, &block)
          else
            value(:filled?, *predicates, **opts, &block)
          end
        end
      end
    end
  end
end
