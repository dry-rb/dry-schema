# frozen_string_literal: true

require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      # A macro used for specifying predicates to be applied to values from a hash
      #
      # @api private
      class Value < DSL
        # @api private
        def call(*predicates, **opts, &block)
          schema = predicates.detect { |predicate| predicate.is_a?(Processor) }

          if schema
            current_type = schema_dsl.types[name]

            updated_type =
              if current_type.respond_to?(:of)
                current_type.of(schema.type_schema)
              else
                schema.type_schema
              end

            schema_dsl.set_type(name, updated_type)
          end

          trace.evaluate(*predicates, **opts)
          trace.append(new(chain: false).instance_exec(&block)) if block

          if trace.captures.empty?
            raise ArgumentError, 'wrong number of arguments (given 0, expected at least 1)'
          end

          type_spec = opts[:type_spec]
          each(type_spec.type.member) if type_spec.respond_to?(:member)

          self
        end

        # @api private
        def respond_to_missing?(meth, include_private = false)
          super || meth.to_s.end_with?(QUESTION_MARK)
        end

        private

        # @api private
        def method_missing(meth, *args, &block)
          if meth.to_s.end_with?(QUESTION_MARK)
            trace.__send__(meth, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end
