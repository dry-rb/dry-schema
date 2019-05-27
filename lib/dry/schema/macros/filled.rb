# frozen_string_literal: true

require 'dry/schema/macros/value'

module Dry
  module Schema
    module Macros
      # Macro used to prepend `:filled?` predicate
      #
      # @api private
      class Filled < Value
        # @api private
        def call(*predicates, **opts, &block)
          ensure_valid_predicates(predicates)

          if opts[:type_spec]
            value(predicates[0], :filled?, *predicates[1..predicates.size - 1], **opts, &block)
          else
            value(:filled?, *predicates, **opts, &block)
          end
        end

        # @api private
        # rubocop:disable Style/GuardClause
        def ensure_valid_predicates(predicates)
          if predicates.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with empty? predicate is invalid'
          end

          if predicates.include?(:filled?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with filled? is redundant'
          end
        end
        # rubocop:enable Style/GuardClause
      end
    end
  end
end
