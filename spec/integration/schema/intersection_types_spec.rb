# frozen_string_literal: true

RSpec.describe "Intersection types" do
  context "with hash schemas" do
    let(:schema) do
      Dry::Schema.Params do
        required(:body).value(
          Types::Hash.schema(a: Types::String) &
          (Types::Hash.schema(b: Types::String) | Types::Hash.schema(c: Types::String))
        )
      end
    end

    it "validates intersection of hash schemas successfully" do
      result = schema.call(body: {a: "test", b: "value"})

      expect(result).to be_success
      expect(result.to_h).to eq(body: {a: "test", b: "value"})
    end

    it "validates intersection with alternative branch" do
      result = schema.call(body: {a: "test", c: "value"})

      expect(result).to be_success
      expect(result.to_h).to eq(body: {a: "test", c: "value"})
    end

    it "fails when intersection requirements not met" do
      result = schema.call(body: {b: "value"})

      expect(result).to be_failure
      expect(result.errors.to_h).to eq(body: {a: ["is missing"]})
    end
  end

  context "with simple type intersection" do
    let(:schema) do
      Dry::Schema.Params do
        required(:value).value(Types::String & Types::Params::String)
      end
    end

    it "validates simple intersection types" do
      result = schema.call(value: "test")

      expect(result).to be_success
      expect(result.to_h).to eq(value: "test")
    end
  end

  context "with DSL predicates and intersection" do
    let(:schema) do
      Dry::Schema.Params do
        required(:name).value(Types::String & Types::Params::String) { filled? & min_size?(2) }
      end
    end

    it "combines type intersection with predicate rules" do
      result = schema.call(name: "John")

      expect(result).to be_success
      expect(result.to_h).to eq(name: "John")
    end

    it "fails when predicate rules not met" do
      result = schema.call(name: "J")

      expect(result).to be_failure
      expect(result.errors.to_h).to eq(name: ["size cannot be less than 2"])
    end
  end
end
