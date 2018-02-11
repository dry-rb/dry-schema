require 'dry/schema/macros/key'
require 'dry/schema/macros/each'

module Dry
  module Schema
    module Macros
      class Required < Key
        def operation
          :and
        end
      end
    end
  end
end
