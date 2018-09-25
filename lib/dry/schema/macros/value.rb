require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Value < Core
        def call(*predicates, **opts, &block)
          predicates.each do |predicate|
            if predicate.respond_to?(:to_ast)
              trace << predicate
            else
              trace.__send__(predicate)
            end
          end

          opts.each do |predicate, *args|
            trace.__send__(predicate, *args)
          end

          if block
            instance_exec(&block)
          end

          if trace.nodes.empty?
            raise ArgumentError, 'wrong number of arguments (given 0, expected at least 1)'
          end

          self
        end

        def to_ast
          trace.to_ast
        end
      end
    end
  end
end
