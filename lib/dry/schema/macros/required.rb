require 'dry/schema/macros/key'

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
