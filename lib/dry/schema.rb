require 'dry/schema/compiler'
require 'dry/schema/dsl'
require 'dry/schema/definition'

module Dry
  module Schema
    # Define a schema
    #
    # @return [Definition]
    #
    # @api public
    def self.define(&block)
      compiler = Compiler.new
      dsl = DSL.new(compiler, &block)

      Definition.new(dsl.call)
    end
  end
end
