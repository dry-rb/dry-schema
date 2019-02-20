module Dry
  module Schema
    module Extensions
      module Hints
        module MessageCompilerMethods
          attr_reader :hints

          def initialize(*args)
            super
            @hints = @options.fetch(:hints, true)
          end

          # @api private
          def hints?
            hints.equal?(true)
          end

          # @api private
          def visit_hint(node, opts = EMPTY_OPTS.dup)
            visit(node, opts.(message_type: :hint)) if hints?
          end

          # @api private
          def visit_each(node, opts = EMPTY_OPTS.dup)
            # TODO: we can still generate a hint for elements here!
            []
          end
        end
      end
    end
  end
end
