# frozen_string_literal: true

module Dry
  module Schema
    module Extensions
      module Hints
        # Hint extensions for MessageSet
        #
        # @api public
        module MessageSetMethods
          # Filtered message hints from all messages
          #
          # @return [Array<Message::Hint>]
          attr_reader :hints

          # Configuration option to enable/disable showing errors
          #
          # @return [Boolean]
          attr_reader :failures

          # @api private
          def initialize(errors, options = EMPTY_HASH)
            super
            @hints = errors.select(&:hint?)
            @failures = options.fetch(:failures, true)
          end

          # Dump message set to a hash with either all messages or just hints
          #
          # @see MessageSet#to_h
          # @see ResultMethods#hints
          #
          # @return [Hash<Symbol=>Array<String>>]
          #
          # @api public
          def to_h
            @to_h ||= failures ? errors_map : errors_map(hints)
          end
          alias_method :to_hash, :to_h

          private

          # @api private
          def unique_paths
            errors.uniq(&:path).map(&:path)
          end

          # @api private
          def errors_map(errors = self.errors)
            return EMPTY_HASH if empty?

            initialize_placeholders!
            errors.reduce(placeholders) { |hash, msg|
              node = msg.path.reduce(hash) { |a, e| a.is_a?(Hash) ? a[e] : a.last[e] }
              (node[0].is_a?(::Array) ? node[0] : node) << msg.dump
              hash
            }
          end

          # @api private
          #
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/PerceivedComplexity
          def initialize_placeholders!
            @placeholders ||= unique_paths.each_with_object(EMPTY_HASH.dup) { |path, hash|
              curr_idx = 0
              last_idx = path.size - 1
              node = hash

              while curr_idx <= last_idx
                key = path[curr_idx]

                next_node =
                  if node.is_a?(Array) && key.is_a?(Symbol)
                    node_hash = (node << [] << {}).last
                    node_hash[key] || (node_hash[key] = curr_idx < last_idx ? {} : [])
                  else
                    node[key] || (node[key] = curr_idx < last_idx ? {} : [])
                  end

                node = next_node
                curr_idx += 1
              end
            }
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/PerceivedComplexity
        end
      end
    end
  end
end
