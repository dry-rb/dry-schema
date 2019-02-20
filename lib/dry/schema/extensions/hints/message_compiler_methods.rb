module Dry
  module Schema
    module Extensions
      module Hints
        module MessageCompilerMethods
          HINT_EXCLUSION = %i(
            key? filled? nil? bool?
            str? int? float? decimal?
            date? date_time? time? hash?
            array? format?
          ).freeze

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
          def filter(messages)
            Array(messages).flatten.reject do |msg|
              case msg
              when Message::Or
                false
              else
                HINT_EXCLUSION.include?(msg.predicate)
              end
            end
          end

          # @api private
          def visit_hint(node, opts = EMPTY_OPTS.dup)
            if hints?
              filter(visit(node, opts.(message_type: :hint)))
            end
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
