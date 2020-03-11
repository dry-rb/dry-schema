# frozen_string_literal: true

require "dry/schema/macros/schema"

module Dry
  module Schema
    module Macros
      # Macro used to specify a nested schema
      #
      # @api private
      class Hash < Schema
        # @api private
        def call(*args, &block)
          if args.size >= 1 && args[0].respond_to?(:keys)
            hash_type = args[0]
            type_predicates = predicate_inferrer[hash_type]
            all_predicats = type_predicates + args.drop(1)

            super(*all_predicats) do
              hash_type.each do |key|
                if key.required?
                  required(key.name).value(key.type)
                else
                  optional(key.name).value(key.type)
                end
                instance_exec(&block) if block
              end
            end
          else
            trace << hash?

            super(*args, &block)
          end
        end
      end
    end
  end
end
