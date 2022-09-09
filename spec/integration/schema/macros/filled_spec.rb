# frozen_string_literal: true

RSpec.describe "Macros #filled" do
  describe "with no args" do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).filled
      end
    end

    it "generates filled? rule" do
      expect(schema.(email: "").messages).to eql(
        email: ["must be filled"]
      )
    end
  end

  describe "with a type specification" do
    context ":string" do
      subject(:schema) do
        Dry::Schema.define do
          required(:name).filled(:string)
        end
      end

      it "generates str? && filled? rule" do
        expect(schema.(name: nil).errors).to eql(name: ["must be a string"])
      end
    end

    context ":integer" do
      context "Params" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:age).filled(:integer)

            required(:address).hash do
              required(:zipcode).filled(:integer)
            end
          end
        end

        it "applies filter(:filled?) for empty strings" do
          expect(schema.(age: "", address: {zipcode: "123"}).errors).to eql(age: ["must be filled"])
        end

        it "applies filter(:filled?) for empty strings under nested keys" do
          expect(schema.(age: "41", address: {zipcode: ""}).errors)
            .to eql(address: {zipcode: ["must be filled"]})
        end

        it "applies filter(:filled?) for nil" do
          expect(schema.(age: nil, address: {zipcode: "123"}).errors)
            .to eql(age: ["must be filled"])
        end

        it "applies int?" do
          expect(schema.(age: "not-a-number", address: {zipcode: "123"}).errors)
            .to eql(age: ["must be an integer"])
        end
      end

      context "JSON" do
        subject(:schema) do
          Dry::Schema.JSON do
            required(:age).filled(:integer)
          end
        end

        it "applies type-spec predicate for empty strings" do
          expect(schema.(age: "").errors).to eql(age: ["must be an integer"])
        end

        it "applies type-spec predicate for nil" do
          expect(schema.(age: nil).errors).to eql(age: ["must be an integer"])
        end

        it "applies int?" do
          expect(schema.(age: "not-a-number").errors).to eql(age: ["must be an integer"])
        end
      end
    end
  end

  describe "with a predicate with args" do
    context "with a flat arg" do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?, gt?: 18)
        end
      end

      it "generates filled? & int? & gt? rule" do
        expect(schema.(age: nil).messages).to eql(
          age: ["must be filled", "must be greater than 18"]
        )
      end
    end

    context "with a range arg" do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?, size?: 18..24)
        end
      end

      it "generates filled? & int? & size? rule" do
        expect(schema.(age: nil).messages).to eql(
          age: ["must be filled", "size must be within 18 - 24"]
        )
      end
    end

    context "with a block" do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled { int? & size?(18..24) }
        end
      end

      it "generates filled? & int? & size? rule" do
        expect(schema.(age: nil).messages).to eql(
          age: ["must be filled", "size must be within 18 - 24"]
        )
      end
    end

    context "with a predicate and a block" do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?) { size?(18..24) }
        end
      end

      it "generates filled? & int? & size? rule" do
        expect(schema.(age: nil).messages).to eql(
          age: ["must be filled", "size must be within 18 - 24"]
        )
      end
    end
  end

  describe "with a constructor type" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).filled(Test::StrippedString)
      end
    end

    before do
      Test::StrippedString = Types::String.constructor(&:strip)
    end

    it "applies constructor before applying filled?" do
      result = schema.(foo: "   ")

      expect(result.to_h).to eql(foo: "")
      expect(result.errors).to eql(foo: ["must be filled"])
    end
  end

  describe "with a constrained constructor type" do
    let(:csv) do
      Types::Array.constrained(max_size: 2).constructor { |s| s.split(",") }
    end

    subject(:schema) do
      csv = self.csv
      Dry::Schema.define do
        required(:foo).filled(csv)
      end
    end

    it "applies constructor before applying filled? and constraints" do
      result = schema.(foo: "")
      expect(result.to_h).to eql(foo: [])
      expect(result.errors).to eql(foo: ["must be filled"])

      result = schema.(foo: "foo,bar")
      expect(result).to be_success
      expect(result.to_h).to eql(foo: %w[foo bar])

      result = schema.(foo: "foo,bar,baz")
      expect(result.to_h).to eql(foo: %w[foo bar baz])
      expect(result.errors).to eql(foo: ["size cannot be greater than 2"])
    end
  end

  describe "nested into further DSLs" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).filled(:array).each do
          filled(:array).each do
            filled(Types::Strict::String)
          end
        end
      end
    end

    it "passes when valid" do
      expect(schema.call(foo: [["bar"]])).to be_success
    end

    it "fails when invalid" do
      expect(schema.call(foo: 1).messages).to eql(foo: ["must be an array"])
      expect(schema.call(foo: []).messages).to eql(foo: ["must be filled"])
      expect(schema.call(foo: [1]).messages).to eql(foo: {0 => ["must be an array"]})
      expect(schema.call(foo: [[]]).messages).to eql(foo: {0 => ["must be filled"]})
      expect(schema.call(foo: [[1]]).messages).to eql(foo: {0 => {0 => ["must be a string"]}})
      expect(schema.call(foo: [[""]]).messages).to eql(foo: {0 => {0 => ["must be filled"]}})
    end
  end
end
