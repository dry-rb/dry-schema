# frozen_string_literal: true

require "dry/schema/extensions/schema_compiler_base"

module Dry
  module Schema
    # @api private
    module JSONSchema
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
            nil?: {type: "null"},
            str?: {type: "string"},
            time?: {type: "string", format: "time"},
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
            gt?: {exclusiveMinimum: SchemaCompilerBase::IDENTITY},
            gteq?: {minimum: SchemaCompilerBase::IDENTITY},
            lt?: {exclusiveMaximum: SchemaCompilerBase::IDENTITY},
            lteq?: {maximum: SchemaCompilerBase::IDENTITY},
            odd?: {type: "integer", not: {multipleOf: 2}},
            even?: {type: "integer", multipleOf: 2}
          }
        end

        def fetch_filled_options(type, _target)
          case type
          when "string"
            {minLength: 1}
          when "array"
            # If we are in strict mode, raise an error if we haven't
            # explicitly handled "filled?" with array
            raise_unknown_conversion_error!(:type, :array) unless loose?

            {not: {type: "null"}}
          else
            {not: {type: "null"}}
          end
        end

        # In JSON Schema, we handle an OR branch with "anyOf"
        def merge_or!(target, new_schema)
          (target[:anyOf] ||= []) << new_schema
        end

        # Info to inject at the root level for JSON Schema
        def schema_info
          {"$schema": "http://json-schema.org/draft-06/schema#"}
        end

        # Useful in error messages
        def schema_type
          "JSON"
        end

        # Used in the unknown_conversion_message to show users how to call json_schema(loose: true)
        def schema_method
          "json_schema"
        end
      end
    end
  end
end
