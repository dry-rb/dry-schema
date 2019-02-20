module Dry
  module Schema
    module Extensions
      module Hints
        module MessageSetMethods
          HINT_EXCLUSION = %i(
            key? filled? nil? bool?
            str? int? float? decimal?
            date? date_time? time? hash?
            array? format?
          ).freeze

          attr_reader :hints, :failures

          # @api private
          def initialize(messages, options = EMPTY_HASH)
            @hints = messages.select(&:hint?)
            @failures = messages - hints
            @hints.reject! { |hint| HINT_EXCLUSION.include?(hint.predicate) }
            super
          end

          # @api public
          def to_h
            failures? ? messages_map : hints_map
          end
          alias_method :to_hash, :to_h
          alias_method :dump, :to_h

          # @api private
          def failures?
            options[:failures].equal?(true)
          end

          private

          # @api private
          def messages_map(messages = failures + hints)
            super
          end

          # @api private
          def hints_map
            messages_map(hints)
          end

          # @api private
          def hint_groups
            @hint_groups ||= hints.group_by(&:path)
          end

          # @api private
          def paths
            @paths ||= failures.map(&:path).uniq
          end
        end
      end
    end
  end
end