# frozen_string_literal: true

require "json_schemer"

RSpec.describe Dry::Schema::JSON, "#json_schema" do
  before do
    Dry::Schema.load_extensions(:json_schema)
  end

  shared_examples "metaschema validation" do
    describe "validating against the metaschema" do
      it "produces a valid json schema document for draft6" do
        input = schema.respond_to?(:json_schema) ? schema.json_schema : schema

        expect(JSONSchemer.validate_schema(input).to_a).to be_empty
      end
    end
  end

  context "when using a realistic schema with nested data" do
    subject(:schema) do
      Dry::Schema.JSON do
        required(:email).value(:string)

        optional(:age).value(:integer)

        required(:roles).array(:hash) do
          required(:name).value(:string, min_size?: 12, max_size?: 36)

          required(:metadata).hash do
            required(:assigned_at).value(:time)
          end
        end

        optional(:address).hash do
          optional(:street).value(:string)
        end

        required(:id) { str? | int? }
      end
    end

    include_examples "metaschema validation"

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          email: {
            type: "string"
          },
          age: {
            type: "integer"
          },
          roles: {
            type: "array",
            items: {
              type: "object",
              properties: {
                name: {
                  type: "string",
                  minLength: 12,
                  maxLength: 36
                },
                metadata: {
                  type: "object",
                  properties: {
                    assigned_at: {
                      format: "time",
                      type: "string"
                    }
                  },
                  required: %w[assigned_at]
                }
              },
              required: %w[name metadata]
            }
          },
          address: {
            type: "object",
            properties: {
              street: {
                type: "string"
              }
            },
            required: []
          },
          id: {
            anyOf: [
              {type: "string"},
              {type: "integer"}
            ]
          }
        },
        required: %w[email roles id]
      )
    end
  end

  context "when using maybe types" do
    include_examples "metaschema validation"

    subject(:schema) do
      Dry::Schema.JSON do
        required(:email).maybe(:string)
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          email: {
            type: %w[null string]
          }
        },
        required: %w[email]
      )
    end
  end

  context "when using maybe array types" do
    include_examples "metaschema validation"

    subject(:schema) do
      Dry::Schema.JSON do
        required(:list).maybe(:array).each(:str?)
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          list: {
            type: %w[null array],
            items: {
              type: "string"
            }
          }
        },
        required: %w[list]
      )
    end
  end

  context "when using maybe array types with nested properties" do
    include_examples "metaschema validation"

    subject(:schema) do
      Dry::Schema.JSON do
        required(:list).maybe(:array).each do
          hash do
            required(:name).value(:string)
          end
        end
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          list: {
            type: %w[null array],
            items: {
              type: "object",
              properties: {
                name: {
                  type: "string"
                }
              },
              required: %w[name]
            }
          }
        },
        required: %w[list]
      )
    end
  end

  context "when using array types with combined schemas" do
    include_examples "metaschema validation"

    subject(:schema) do
      schema_1 = Dry::Schema.JSON do
        required(:name).value(:string)
      end

      schema_2 = Dry::Schema.JSON do
        optional(:age).value(:string)
      end

      Dry::Schema.JSON do
        required(:list).value(:array).each { schema_1 | schema_2 }
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          list: {
            type: "array",
            items: {
              anyOf: [
                {
                  type: "object",
                  properties: {
                    name: {
                      type: "string"
                    }
                  },
                  required: %w[name]
                },
                {
                  type: "object",
                  properties: {
                    age: {
                      type: "string"
                    }
                  },
                  required: []
                }
              ]
            }
          }
        },
        required: %w[list]
      )
    end
  end

  context "when using value which is an OR of different types of arrays" do
    include_examples "metaschema validation"

    subject(:schema) do
      string_array = Types::Array.of(Types::String)
      integer_array = Types::Array.of(Types::Integer)

      Dry::Schema.JSON do
        required(:list).value(string_array | integer_array)
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          list: {
            anyOf: [
              {
                type: "array",
                items: {
                  type: "string"
                }
              },
              {
                type: "array",
                items: {
                  type: "integer"
                }
              }
            ]
          }
        },
        required: %w[list]
      )
    end
  end

  describe "filled macro" do
    context "when there is no type" do
      include_examples "metaschema validation"

      subject(:schema) do
        Dry::Schema.JSON do
          required(:email).filled
        end
      end

      it "returns the correct json schema" do
        expect(schema.json_schema).to include(
          properties: {
            email: {
              not: {type: "null"}
            }
          }
        )
      end
    end

    context "when its a string type" do
      include_examples "metaschema validation"

      subject(:schema) do
        Dry::Schema.JSON do
          required(:email).filled(:str?)
        end
      end

      it "returns the correct json schema" do
        expect(schema.json_schema).to include(
          properties: {
            email: {
              type: "string",
              minLength: 1
            }
          }
        )
      end
    end

    context "when its an array type" do
      subject(:schema) do
        Dry::Schema.JSON do
          required(:tags).filled(:array)
        end
      end

      it "raises an unknown type conversion error (fix later)" do
        expect { schema.json_schema }.to raise_error(
          Dry::Schema::JSONSchema::SchemaCompiler::UnknownConversionError
        )
      end
    end
  end

  context "when using non-convertible types" do
    unsupported_cases = [
      Types.Constructor(Struct.new(:name)),
      {excluded_from?: ["foo"]},
      {format?: /something/},
      {bytesize?: 2}
    ]

    unsupported_cases.each do |predicate|
      subject(:schema) do
        Dry::Schema.JSON do
          required(:nested).hash do
            if predicate.is_a?(Hash)
              required(:key).filled(**predicate)
            else
              required(:key).filled(predicate)
            end
          end
        end
      end

      it "raises an unknown type conversion error by default" do
        expect { schema.json_schema }.to raise_error(
          Dry::Schema::JSONSchema::SchemaCompiler::UnknownConversionError, /predicate/
        )
      end

      it "allows for the schema to be generated loosely" do
        expect { schema.json_schema(loose: true) }.not_to raise_error
      end
    end
  end

  context "when using enums" do
    include_examples "metaschema validation"

    subject(:schema) do
      Dry::Schema.JSON do
        required(:color).value(:str?, included_in?: %w[red blue])
        required(:shade).maybe(array[Types::String.enum("light", "medium", "dark")])
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          color: {
            type: "string",
            enum: %w[red blue]
          },
          shade: {
            type: %w[null array],
            items: {
              type: "string",
              enum: %w[light medium dark]
            }
          }
        },
        required: %w[color shade]
      )
    end
  end

  context "when using const" do
    include_examples "metaschema validation"

    subject(:schema) do
      Dry::Schema.JSON do
        required(:version).value(:integer, eql?: 1)
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          version: {
            type: "integer",
            const: 1
          }
        },
        required: %w[version]
      )
    end
  end

  describe "inferring types" do
    {
      array: {type: "array"},
      bool: {type: "boolean"},
      date: {type: "string", format: "date"},
      date_time: {type: "string", format: "date-time"},
      decimal: {type: "number"},
      float: {type: "number"},
      hash: {type: "object"},
      integer: {type: "integer"},
      nil: {type: "null"},
      string: {type: "string"},
      time: {type: "string", format: "time"},
      uuid_v1?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-1[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v2?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-2[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v3?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v4?: {pattern: "^[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}$"},
      uuid_v5?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v6?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-6[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v7?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-7[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"},
      uuid_v8?: {pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-8[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"}
    }.each do |type_spec, type_opts|
      describe "type: #{type_spec.inspect}" do
        subject(:schema) do
          Dry::Schema.define { required(:key).value(type_spec) }.json_schema
        end

        include_examples "metaschema validation"

        it "infers with correct default options - #{type_opts.to_json}" do
          expect(schema).to include(
            type: "object",
            properties: {key: type_opts},
            required: ["key"]
          )
        end
      end
    end
  end

  describe "special string predictes" do
    {
      {uri?: "https"} => {type: "string", format: "uri"},
      {size?: 5} => {type: "string", minLength: 5, maxLength: 5},
      {format?: /\A\d{3}-\d{4}\z/} => {type: "string", pattern: "\\A\\d{3}-\\d{4}\\z"}
    }.each do |type_spec, type_opts|
      describe "type: #{type_spec.inspect}" do
        subject(:schema) do
          Dry::Schema.define { required(:key).value(:string, **type_spec) }.json_schema
        end

        include_examples "metaschema validation"

        it "infers with correct default options - #{type_opts.to_json}" do
          expect(schema).to include(
            properties: {key: type_opts}
          )
        end
      end
    end
  end

  describe "special number predictes" do
    {
      {gt?: 5} => {type: "integer", exclusiveMinimum: 5},
      {gteq?: 5} => {type: "integer", minimum: 5},
      {lt?: 5} => {type: "integer", exclusiveMaximum: 5},
      {lteq?: 5} => {type: "integer", maximum: 5},
      odd?: {type: "integer", not: {multipleOf: 2}},
      even?: {type: "integer", multipleOf: 2}
    }.each do |type_spec, type_opts|
      describe "type: #{type_spec.inspect}" do
        subject(:schema) do
          if type_spec.is_a?(Hash)
            Dry::Schema.define { required(:key).value(:int?, **type_spec) }.json_schema
          else
            Dry::Schema.define { required(:key).value(type_spec) }.json_schema
          end
        end

        include_examples "metaschema validation"

        it "infers with correct default options - #{type_opts.to_json}" do
          expect(schema).to include(
            properties: {key: type_opts}
          )
        end
      end
    end
  end

  describe "special boolean predicates" do
    {
      true?: {},
      false?: {}
    }.each do |type_spec, type_opts|
      describe "type: #{type_spec.inspect}" do
        subject(:schema) do
          Dry::Schema.define { required(:key).value(type_spec) }.json_schema
        end

        include_examples "metaschema validation"

        it "infers with correct default options - #{type_opts.to_json}" do
          expect(schema).to include(
            properties: {key: type_opts}
          )
        end
      end
    end
  end

  context "when a type has json_schema meta" do
    let(:schema) do
      Dry::Schema.JSON do
        required(:email).filled(
          Dry::Types["string"].meta(json_schema: {description: "Email address", example: "a@b.com"})
        )
        optional(:age).filled(
          Dry::Types["integer"].meta(json_schema: {description: "Age in years"})
        )
        required(:name).filled(:string)
      end
    end

    include_examples "metaschema validation"

    it "merges json_schema meta into property output" do
      result = schema.json_schema
      expect(result[:properties][:email]).to include(description: "Email address", example: "a@b.com")
      expect(result[:properties][:age]).to include(description: "Age in years")
      expect(result[:properties][:name]).to eq({type: "string", minLength: 1})
    end

    context "with nested hash" do
      let(:schema) do
        Dry::Schema.JSON do
          required(:address).hash do
            required(:street).filled(
              Dry::Types["string"].meta(json_schema: {description: "Street name"})
            )
          end
        end
      end

      include_examples "metaschema validation"

      it "merges json_schema meta into nested property output" do
        result = schema.json_schema
        expect(result[:properties][:address][:properties][:street]).to include(description: "Street name")
      end
    end

    context "with array of hashes" do
      let(:schema) do
        Dry::Schema.JSON do
          required(:roles).array(:hash) do
            required(:name).filled(
              Dry::Types["string"].meta(json_schema: {description: "Role name"})
            )
          end
        end
      end

      include_examples "metaschema validation"

      it "merges json_schema meta into array member property output" do
        result = schema.json_schema
        expect(result[:properties][:roles][:items][:properties][:name]).to include(description: "Role name")
      end
    end
  end

  context "when a type has a dry-types default value" do
    it "serializes primitive defaults" do
      schema = Dry::Schema.JSON do
        required(:role).value(Dry::Types["string"].default("user".freeze))
        required(:count).value(Dry::Types["integer"].default(0))
        required(:name).filled(:string)
      end

      result = schema.json_schema
      expect(result[:properties][:role]).to include(default: "user")
      expect(result[:properties][:count]).to include(default: 0)
      expect(result[:properties][:name]).not_to have_key(:default)
    end

    it "serializes Date default as ISO 8601 string" do
      schema = Dry::Schema.JSON do
        required(:on).value(Dry::Types["date"].default(Date.new(2026, 6, 28).freeze))
      end
      expect(schema.json_schema[:properties][:on]).to include(default: "2026-06-28")
    end

    it "serializes Time default as ISO 8601 string" do
      schema = Dry::Schema.JSON do
        required(:at).value(Dry::Types["time"].default(Time.utc(2026, 6, 28, 10, 0, 0).freeze))
      end
      expect(schema.json_schema[:properties][:at]).to include(default: "2026-06-28T10:00:00Z")
    end

    it "serializes Array default recursively" do
      schema = Dry::Schema.JSON do
        required(:tags).value(Dry::Types["array"].default(["ruby", "rails"].freeze))
      end
      expect(schema.json_schema[:properties][:tags]).to include(default: ["ruby", "rails"])
    end

    it "serializes Hash default with string keys" do
      schema = Dry::Schema.JSON do
        required(:meta).value(Dry::Types["hash"].default({"env" => "prod"}.freeze))
      end
      expect(schema.json_schema[:properties][:meta]).to include(default: {"env" => "prod"})
    end

    it "serializes Symbol default as string" do
      schema = Dry::Schema.JSON do
        required(:tags).value(Dry::Types["array"].default([:foo, :bar].freeze))
      end
      expect(schema.json_schema[:properties][:tags]).to include(default: ["foo", "bar"])
    end

    it "serializes BigDecimal default as float" do
      schema = Dry::Schema.JSON do
        required(:amount).value(Dry::Types["decimal"].default(BigDecimal("1000")))
      end
      expect(schema.json_schema[:properties][:amount]).to include(default: 1000.0)
    end

    it "omits default when a hash value is not JSON-serializable" do
      schema = Dry::Schema.JSON do
        required(:thing).value(Dry::Types["any"].default(Object.new.freeze))
      end
      expect(schema.json_schema[:properties][:thing]).not_to have_key(:default)
    end

    it "converts symbol hash keys to strings" do
      schema = Dry::Schema.JSON do
        required(:meta).value(Dry::Types["hash"].default({env: "prod", count: 1}.freeze))
      end
      expect(schema.json_schema[:properties][:meta]).to include(default: {"env" => "prod", "count" => 1})
    end

    it "omits default when a hash key is not JSON-serializable" do
      schema = Dry::Schema.JSON do
        required(:meta).value(Dry::Types["hash"].default({Object.new => "bad"}.freeze))
      end
      expect(schema.json_schema[:properties][:meta]).not_to have_key(:default)
    end
  end

  context "when using .documentation chaining" do
    let(:schema) do
      Dry::Schema.JSON do
        required(:email).filled(:string).documentation(description: "User email", example: "a@b.com")
        optional(:age).filled(:integer).documentation(description: "Age in years")
        required(:name).filled(:string)
      end
    end

    include_examples "metaschema validation"

    it "merges documentation attrs into property output" do
      result = schema.json_schema
      expect(result[:properties][:email]).to include(description: "User email", example: "a@b.com")
      expect(result[:properties][:age]).to include(description: "Age in years")
      expect(result[:properties][:name]).to eq({type: "string", minLength: 1})
    end

    it "works with value (not filled)" do
      schema = Dry::Schema.JSON do
        required(:code).value(:string).documentation(description: "Access code")
      end
      expect(schema.json_schema[:properties][:code]).to include(description: "Access code")
    end

    it "works inside nested hash" do
      schema = Dry::Schema.JSON do
        required(:address).hash do
          required(:street).filled(:string).documentation(description: "Street name")
        end
      end
      expect(schema.json_schema[:properties][:address][:properties][:street]).to include(description: "Street name")
    end

    it "works on a hash key itself" do
      schema = Dry::Schema.JSON do
        required(:address).hash do
          required(:street).filled(:string)
        end.documentation(description: "Mailing address")
      end
      expect(schema.json_schema[:properties][:address]).to include(type: "object", description: "Mailing address")
    end

    it "raises if called before a type is set" do
      expect {
        Dry::Schema.JSON { required(:email).documentation(description: "bad").filled(:string) }
      }.to raise_error(Dry::Schema::InvalidSchemaError, /after a type is set/)
    end

    it "rejects :default (use dry-schema native default instead)" do
      expect {
        Dry::Schema.JSON do
          required(:foo).filled(:string).documentation(default: "bar")
        end
      }.to raise_error(ArgumentError, /unknown keyword.*default/)
    end

    it "passes all supported keys through to the output" do
      doc = {
        title: "Foo",
        description: "A foo",
        examples: ["bar"],
        example: "bar",
        deprecated: true,
      }
      schema = Dry::Schema.JSON do
        required(:foo).filled(:string).documentation(**doc)
      end
      expect(schema.json_schema[:properties][:foo]).to include(
        type: "string",
        minLength: 1,
        **doc,
      )
    end

    it "omits deprecated when false" do
      props = Dry::Schema.JSON do
        required(:foo).filled(:string).documentation(deprecated: false)
      end.json_schema[:properties][:foo]

      expect(props).not_to have_key(:deprecated)
    end

    it "serializes example: Date to iso8601 string" do
      schema = Dry::Schema.JSON do
        required(:foo).filled(:date).documentation(example: ::Date.new(2024, 1, 15))
      end
      expect(schema.json_schema[:properties][:foo][:example]).to eq("2024-01-15")
    end

    it "serializes examples: [Date] elements to iso8601 strings" do
      schema = Dry::Schema.JSON do
        required(:foo).filled(:date).documentation(examples: [::Date.new(2024, 1, 1), ::Date.new(2024, 6, 30)])
      end
      expect(schema.json_schema[:properties][:foo][:examples]).to eq(["2024-01-01", "2024-06-30"])
    end
  end
end
