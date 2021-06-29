# frozen_string_literal: true

require "json"

RSpec.describe "Params / Constructor Types" do
  context "an array which rejects empty values" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:nums).filled(Test::SanitizedArray)
      end
    end

    before do
      module Test
        SanitizedArray = Types::Params::Array
          .of(Types::Params::Integer)
          .constructor { |arr| arr.reject(&:empty?) }
      end
    end

    it "passes even when the array includes empty values" do
      result = schema.(nums: ["1", "", "2"])

      expect(result).to be_success
      expect(result.to_h).to eql(nums: [1, 2])
    end

    it "fails when the array is empty" do
      result = schema.(nums: ["", ""])

      expect(result.errors).to eql(nums: ["must be filled"])
      expect(result.to_h).to eql(nums: [])
    end
  end

  context "an array that coerces values to hashes" do
    subject(:schema) do
      Dry::Schema.define do
        nested_schema = Dry::Schema.define do
          required(:inner_field).filled(:integer)
        end

        array_type = Types::Strict::Array
                       .of(nested_schema)
                       .constructor { |value| value.map { |el| Marshal.load(el) } }

        required(:outer_field).filled(array_type)
      end
    end

    it "uses the constructor" do
      expect(schema.(outer_field: [Marshal.dump(inner_field: 1), Marshal.dump(inner_field: 2)]).to_h)
        .to eql(outer_field: [{inner_field: 1}, {inner_field: 2}])
    end
  end

  context "using Params processor and custom constructor types" do
    context "with a params hash" do
      subject(:schema) do
        Dry::Schema.Params do
          required(:foo).filled(Types::Params::Hash)
        end
      end

      let(:input) do
        {foo: { "bar" => 123 }}
      end

      it "applies predicates" do
        result = schema.(foo: "")

        expect(result).to be_failure
        expect(result.errors.to_h).to eql(foo: ["must be filled"])

        result = schema.(foo: ["not a hash"])

        expect(result).to be_failure
        expect(result.errors.to_h).to eql(foo: ["must be a hash"])
      end
    end

    context "with a custom json hash" do
      subject(:schema) do
        Dry::Schema.Params do
          required(:foo).filter(:filled?).value(Types::Hash.constructor(&JSON.method(:parse)))
        end
      end

      let(:input) do
        {foo: JSON.dump({ "bar" => 123 })}
      end

      it "applies predicates" do
        result = schema.(foo: "")

        expect(result).to be_failure
        expect(result.errors.to_h).to eql(foo: ["must be filled"])

        result = schema.(foo: ["not a hash"])

        expect(result).to be_failure
        expect(result.errors.to_h).to eql(foo: ["must be a hash"])
      end

      it "uses the constructor" do
        result = schema.(input)

        expect(result).to be_success
        expect(result.to_h).to eql(foo: JSON.load(input[:foo]))
      end
    end
  end

  context "using Schema processor" do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe(Types::String.constructor(&:upcase))
      end
    end

    it "uses the constructor" do
      expect(schema.(name: nil)[:name]).to be_nil
      expect(schema.(name: "John")[:name]).to eql("JOHN")
    end
  end
end
