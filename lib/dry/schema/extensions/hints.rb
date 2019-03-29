# frozen_string_literal: true

require 'dry/schema/compiler'
require 'dry/schema/message'
require 'dry/schema/message_compiler'

require 'dry/schema/extensions/hints/compiler_methods'
require 'dry/schema/extensions/hints/message_compiler_methods'
require 'dry/schema/extensions/hints/message_set_methods'
require 'dry/schema/extensions/hints/result_methods'

module Dry
  module Schema
    # Hint-specific Message extensions
    #
    # @see Message
    #
    # @api public
    class Message
      # @see Message::Or
      #
      # @api public
      class Or
        # @api private
        def hint?
          false
        end
      end

      # @api private
      def hint?
        false
      end
    end

    # A hint message sub-type
    #
    # @api private
    class Hint < Message
      # @api private
      def hint?
        true
      end
    end

    module Extensions
      Compiler.prepend(Hints::CompilerMethods)
      MessageCompiler.prepend(Hints::MessageCompilerMethods)
      MessageSet.prepend(Hints::MessageSetMethods)
      Result.prepend(Hints::ResultMethods)
    end
  end
end
