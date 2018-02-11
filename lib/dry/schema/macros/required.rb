require 'dry/schema/macros/key'
require 'dry/schema/macros/each'

module Dry
  module Schema
    module Macros
      class Required < Key
        def each(*args, &block)
          macro = Each.new(nil)
          macro.value(*args, &block)
          trace << macro
          self
        end

        def operation
          :and
        end
      end
    end
  end
end
