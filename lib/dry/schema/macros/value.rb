require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      class Value < DSL
        def call(*predicates, **opts, &block)
          trace.evaluate(*predicates, **opts, &block)

          trace.append(new(chain: false).instance_exec(&block)) if block

          if trace.captures.empty?
            raise ArgumentError, 'wrong number of arguments (given 0, expected at least 1)'
          end

          self
        end

        def respond_to_missing?(meth, include_private = false)
          super || meth.to_s.end_with?(QUESTION_MARK)
        end

        private

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
