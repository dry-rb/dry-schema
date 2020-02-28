# frozen_string_literal: true

require 'dry/schema/macros/schema'

module Dry
  module Schema
    module Macros
      # Macro used to specify a nested schema
      #
      # @api private
      class Hash < Schema
        # @api private
        def call(*args, &block)
          trace << hash?

          if args.size >= 1 && args[0].respond_to?(:keys)
            hash_type = args[0]

            super(*args.drop(1)) do
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
            super(*args, &block)
          end
        end
      end
    end
  end
end
