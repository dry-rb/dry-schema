# frozen_string_literal: true

RSpec.describe "JSON Schema with array size predicates" do
  before do
    Dry::Schema.load_extensions(:json_schema)
  end

  context "with min_size? and max_size? predicates" do
    let(:schema) do
      Dry::Schema.JSON do
        required(:users).value(:array?, min_size?: 5, max_size?: 10).each(:str?)
      end
    end

    it "generates minItems and maxItems on array" do
      json_schema = schema.json_schema

      expect(json_schema[:properties][:users]).to include(
        type: "array",
        minItems: 5,
        maxItems: 10,
        items: { type: "string" }
      )

      expect(json_schema[:properties][:users][:items]).not_to have_key(:minLength)
      expect(json_schema[:properties][:users][:items]).not_to have_key(:maxLength)
    end
  end

  context "with string items having size predicates" do
    let(:schema) do
      Dry::Schema.JSON do
        required(:names).value(:array?, min_size?: 2).each(:str?, min_size?: 3, max_size?: 50)
      end
    end

    it "applies array size to array and string size to items" do
      json_schema = schema.json_schema

      expect(json_schema[:properties][:names]).to include(
        type: "array",
        minItems: 2,
        items: {
          type: "string",
          minLength: 3,
          maxLength: 50
        }
      )
    end
  end

  context "with equal min and max size constraints" do
    let(:schema) do
      Dry::Schema.JSON do
        required(:users).value(:array?, min_size?: 5, max_size?: 5).each(:str?)
      end
    end

    it "generates correct minItems and maxItems" do
      expected = {
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          users: {
            type: "array",
            minItems: 5,
            maxItems: 5,
            items: {
              type: "string"
            }
          }
        },
        required: ["users"]
      }

      expect(schema.json_schema).to eq(expected)
    end
  end
end
