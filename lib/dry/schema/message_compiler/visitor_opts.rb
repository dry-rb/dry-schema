module Dry
  module Schema
    class MessageCompiler
      class VisitorOpts < Hash
        def self.new
          opts = super
          opts[:path] = EMPTY_ARRAY
          opts[:rule] = nil
          opts[:message_type] = :failure
          opts
        end

        def path
          self[:path]
        end

        def call(other)
          merge(other.update(path: [*path, *other[:path]]))
        end
      end
    end
  end
end
