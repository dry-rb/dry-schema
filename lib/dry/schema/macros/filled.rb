require 'dry/schema/macros/value'

module Dry
  module Schema
    module Macros
      class Filled < Value
        def call(*args, &block)
          if args.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, "Using filled with empty? predicate is invalid"
          end

          if args.include?(:filled?)
            raise ::Dry::Schema::InvalidSchemaError, "Using filled with filled? is redundant"
          end

          value(:filled?, *args, &block)
        end
      end
    end
  end
end
