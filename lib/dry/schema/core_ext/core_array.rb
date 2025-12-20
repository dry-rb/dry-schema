# frozen_string_literal: true

module Dry
  module Schema
    module CoreExt
      # @api private
      module CoreArray
        refine Array do
          # @api private
          def start_with?(prefix) = self[0, prefix.length] == prefix

          # @api private
          def delete_prefix(prefix)
            start_with?(prefix) ? self[prefix.length, length] : dup
          end
        end
      end
    end
  end
end
