# frozen_string_literal: true

RSpec.describe "Params / Macros / array" do
  context "array of hashes" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:songs).array(:hash) do
          required(:title).filled(:string)
        end
      end
    end

    it "coerces an empty string to an array" do
      result = schema.("songs" => "")

      expect(result).to be_success
      expect(result.to_h).to eq(songs: [])
    end
  end

  context "when inherited" do
    subject(:schema) do
      Dry::Schema.Params(parent: parent) do
        optional(:user).array(:hash)
      end
    end

    let(:parent) do
      Dry::Schema.Params do
        optional(:id).value(:integer)
      end
    end

    it "applies coercion and rules" do
      result = schema.("id" => "1", "user" => nil)

      expect(result.errors.to_h).to eql(user: ["must be an array"])
      expect(result.to_h).to eql(id: 1, user: nil)
    end

    context "from multiple parents" do
      subject(:schema) do
        Dry::Schema.Params(parent: [parent, parent2]) do
          optional(:user).array(:hash)
        end
      end

      let(:parent2) do
        Dry::Schema.Params do
          optional(:age).value(:integer, gt?: 17)
        end
      end

      it "applies coercion and rules from both parents" do
        result = schema.("id" => "1", "age" => "12", "user" => nil)

        expect(result.errors.to_h).to eql(user: ["must be an array"],
                                          age: ["must be greater than 17"])
        expect(result.to_h).to eql(id: 1, user: nil, age: 12)
      end
    end
  end

  context "with a sum type as member" do
    it "applies coercion and rules" do
      schema = Dry::Schema.Params {
        required(:nums).array(Types::Params::Integer | Types::Params::Nil)
      }

      result = schema.(nums: ["3", nil, "1"])

      expect(result).to be_success

      result = schema.(nums: ["3", {}, "1"])

      expect(result).to be_failure
      expect(result.errors.to_h).to eql(nums: {1 => ["must be an integer or cannot be defined"]})
    end

    it "applies coercion and rules to hashes" do
      schema = Dry::Schema.Params {
        required(:hashes).array(
          Types::Hash.schema(name: "string") | Types::Hash.schema(other_name: "string")
        )
      }

      result = schema.(hashes: [{name: "string"}, {name: "string", other_name: "string"}, {other_name: "string"}])

      expect(result).to be_success
      expect(result.output).to eql(hashes: [
        {name: "string"},
        {name: "string"},
        {other_name: "string"}
      ])

      result = schema.(hashes: [{name: "string"}, {other_key: 1}, {name: 0}, {other_name: "string"}])

      expect(result).to be_failure
      expect(result.errors.to_h).to eq(hashes: {1 => {or: [{name: ["is missing"]}, {other_name: ["is missing"]}]}, 2 => {or: [{name: ["must be a string"]}, {other_name: ["is missing"]}]}})
    end
  end
end
