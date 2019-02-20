require 'dry/schema/message'

module Dry
  module Schema
    # @api private
    class MessageCompiler
      # Optimized option hash used by visitor methods in message compiler
      #
      # @api private
      class VisitorOpts < Hash
        # @api private
        def self.new
          opts = super
          opts[:path] = EMPTY_ARRAY
          opts[:rule] = nil
          opts[:message_type] = :failure
          opts
        end

        # @api private
        def path
          self[:path]
        end

        # @api private
        def call(other)
          merge(other.update(path: [*path, *other[:path]]))
        end
      end
    end
  end
end
