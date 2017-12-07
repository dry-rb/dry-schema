require 'dry/schema/compiler'
require 'dry/schema/definition'

module Dry
  module Schema
    # Define a schema
    #
    # @return [Definition]
    #
    # @api public
    def self.define(&block)
      Definition.new(Compiler.new, &block)
    end
  end
end
