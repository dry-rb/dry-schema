# frozen_string_literal: true

RSpec.describe Dry::Schema::JSON, "#json_schema" do
  before do
    Dry::Schema.load_extensions(:json_schema)
  end

  context "when using a realistic schema with nested data" do
    subject(:schema) do
      Dry::Schema.JSON do
        required(:email).filled(:string)

        optional(:age).filled(:integer)

        required(:roles).array(:hash) do
          required(:name).filled(:string, min_size?: 12, max_size?: 36)
        end

        optional(:address).hash do
          optional(:street).filled(:string)
        end
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
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
                }
              },
              required: ["name"]
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
          }
        },
        required: %w[email roles]
      )
    end
  end

  context "when using maybe types" do
    subject(:schema) do
      Dry::Schema.JSON do
        required(:email).maybe(:string)
      end
    end

    it "returns the correct json schema" do
      expect(schema.json_schema).to eql(
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
      time: {type: "string", format: "time"}
    }.each do |type_spec, type_opts|
      it "infers #{type_opts} from '#{type_spec}'" do
        expect(Dry::Schema.define { required(:key).value(type_spec) }.json_schema).to eql(
          type: "object",
          properties: {key: type_opts},
          required: ["key"]
        )
      end
    end
  end
end
