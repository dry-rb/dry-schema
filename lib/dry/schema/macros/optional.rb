require 'dry/schema/macros/key'

module Dry
  module Schema
    module Macros
      class Optional < Key
        def operation
          :then
        end
      end
    end
  end
end
