# frozen_string_literal: true

require "dry-struct"
require "dry/schema/extensions/struct"

RSpec.describe "JSON Schema with struct constructors" do
  before do
    Dry::Schema.load_extensions(:json_schema)
  end

  let(:address_struct) do
    Class.new(Dry::Struct) do
      attribute :street, Types::Strict::String.optional.default(nil)
      attribute :city, Types::Strict::String
    end
  end

  context "with direct struct" do
    let(:schema) do
      struct = address_struct
      Dry::Schema.Params do
        required(:address).value(struct)
      end
    end

    it "generates JSON schema with struct properties" do
      json_schema = schema.json_schema

      expect(json_schema[:properties][:address]).to include(
        type: "object",
        properties: {
          street: { anyOf: [{ type: "null" }, { type: "string" }] },
          city: { type: "string" }
        },
        required: ["street", "city"]
      )
    end
  end

  context "with struct constructor" do
    let(:schema) do
      struct = address_struct
      Dry::Schema.Params do
        required(:address).value(struct.constructor(&:itself))
      end
    end

    it "generates JSON schema with struct properties" do
      json_schema = schema.json_schema

      expect(json_schema[:properties][:address]).to include(
        type: "object",
        properties: {
          street: { anyOf: [{ type: "null" }, { type: "string" }] },
          city: { type: "string" }
        },
        required: ["street", "city"]
      )
    end
  end

  context "comparing direct struct vs constructor" do
    let(:direct_schema) do
      struct = address_struct
      Dry::Schema.Params do
        required(:address).value(struct)
      end
    end

    let(:constructor_schema) do
      struct = address_struct
      Dry::Schema.Params do
        required(:address).value(struct.constructor(&:itself))
      end
    end

    it "generates identical JSON schemas" do
      expect(direct_schema.json_schema).to eq(constructor_schema.json_schema)
    end
  end
end
