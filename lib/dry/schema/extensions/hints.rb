require 'dry/schema/message_compiler'

require 'dry/schema/extensions/hints/message_compiler_methods'
require 'dry/schema/extensions/hints/message_set_methods'
require 'dry/schema/extensions/hints/result_methods'

module Dry
  module Schema
    module Extensions
      MessageCompiler.prepend(Hints::MessageCompilerMethods)
      MessageSet.prepend(Hints::MessageSetMethods)
      Result.prepend(Hints::ResultMethods)
    end
  end
end
