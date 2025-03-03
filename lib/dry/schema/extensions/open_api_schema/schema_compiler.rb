# frozen_string_literal: true

require "dry/schema/extensions/schema_compiler_base"

module Dry
  module Schema
    # @api private
    module OpenAPISchema
      # @api private
      class SchemaCompiler < SchemaCompilerBase::Base
        def predicate_to_type
          {
            array?: {type: "array"},
            bool?: {type: "boolean"},
            date?: {type: "string", format: "date"},
            date_time?: {type: "string", format: "date-time"},
            decimal?: {type: "number"},
            float?: {type: "number"},
            hash?: {type: "object"},
            int?: {type: "integer"},
            nil?: {nullable: true},
            str?: {type: "string"},
            time?: {type: "string", format: "date-time"},
            min_size?: {minLength: SchemaCompilerBase::TO_INTEGER},
            max_size?: {maxLength: SchemaCompilerBase::TO_INTEGER},
            included_in?: {enum: ->(v, _) { v.to_a }},
            filled?: EMPTY_HASH,
            uri?: {format: "uri"},
            uuid_v1?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-1[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
            uuid_v2?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-2[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
            uuid_v3?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
            uuid_v4?: {pattern: "^[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}$"},
            uuid_v5?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
            gt?: {minimum: SchemaCompilerBase::IDENTITY, exclusiveMinimum: true},
            gteq?: {minimum: SchemaCompilerBase::IDENTITY},
            lt?: {maximum: SchemaCompilerBase::IDENTITY, exclusiveMaximum: true},
            lteq?: {maximum: SchemaCompilerBase::IDENTITY},
            odd?: {type: "integer", not: {multipleOf: 2}},
            even?: {type: "integer", multipleOf: 2}
          }
        end

        def fetch_filled_options(type, target)
          case type
          when "string"
            {minLength: 1}
          when "array"
            target[:minItems] = 1
            {}
          else
            {}
          end
        end

        # In OpenAPI, we want to use "oneOf" instead of "anyOf"
        def merge_or!(target, new_schema)
          (target[:oneOf] ||= []) << new_schema
        end

        # We do not support the `root`. If we did we'd have to include
        # all required OpenAPI root properties that require additional info.
        def schema_info
          {}
        end

        # Useful in error messages
        def schema_type
          "OpenAPI"
        end

        # Used in the unknown_conversion_message to show users how to call json_schema(loose: true)
        def schema_method
          "open_api_schema"
        end
      end
    end
  end
end
