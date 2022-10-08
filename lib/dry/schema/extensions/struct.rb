# frozen_string_literal: true

require "dry/struct"

module Dry
  module Schema
    module Macros
      Hash.prepend(::Module.new {
        def call(*args)
          if args.size >= 1 && args[0].is_a?(::Class) && args[0] <= ::Dry::Struct
            if block_given?
              raise ArgumentError, "blocks are not supported when using "\
                                   "a struct class (#{name.inspect} => #{args[0]})"
            end

            super(args[0].schema, *args.drop(1))
            type(schema_dsl.types[name].constructor(args[0].schema))
          else
            super
          end
        end
      })
    end

    PredicateInferrer::Compiler.send(:alias_method, :visit_struct, :visit_hash)
    PrimitiveInferrer::Compiler.send(:alias_method, :visit_struct, :visit_hash)
  end
end
