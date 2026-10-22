# frozen_string_literal: true

RSpec.describe "struct extension" do
  before { Dry::Schema.load_extensions(:struct) }

  let(:struct) do
    Dry.Struct(name: "string", email: "string")
  end

  context "inferring schemas from structs" do
    let(:schema) do
      struct = self.struct

      Dry::Schema.define do
        required(:foo).hash(struct)
      end
    end

    let(:input) { {foo: {name: "John"}} }

    it "infers predicates from struct" do
      expect(result).to be_failing(email: ["is missing", "must be a string"])
    end

    context "extra predicates" do
      let(:schema) do
        struct = self.struct

        Dry::Schema.define do
          required(:foo).hash(struct, :filled?)
        end
      end

      let(:input) { {foo: {}} }

      it "adds predicates" do
        expect(result).to be_failing(["must be filled"])
      end
    end

    context "more options" do
      it "raises an error when a block is given (not supported)" do
        struct = self.struct
        expect { Dry::Schema.define { required(:foo).hash(struct) {} } }.to raise_error(
          ArgumentError,
          /blocks are not supported/
        )
      end
    end

    context "complex struct" do
      let(:struct) do
        Class.new(Dry::Struct) do
          attribute :name, Types::String
          attribute :addresses, Types::Array do
            attribute  :city,   Types::String
            attribute? :street, Types::String
          end
        end
      end

      context "with valid input" do
        let(:input) do
          {foo: {name: "Jane", addresses: [{city: "New York"}]}}
        end

        it "has no errors" do
          expect(schema.(input).errors.to_h).to eq({})
        end
      end

      context "with empty nested array" do
        let(:input) do
          {foo: {name: "Jane", addresses: []}}
        end

        it "has no errors" do
          expect(schema.(input).errors.to_h).to eq({})
        end
      end
    end
  end

  context "value macro" do
    let(:schema) do
      struct = self.struct

      Dry::Schema.define do
        required(:foo).value(struct)
      end
    end

    let(:input) { {foo: {name: "John"}} }

    it "infers predicates from struct" do
      expect(result).to be_failing(email: ["is missing", "must be a string"])
    end

    context "complex struct" do
      let(:struct) do
        Class.new(Dry::Struct) do
          attribute :name, Types::String
          attribute :addresses, Types::Array do
            attribute  :city,   Types::String
            attribute? :street, Types::String
          end
        end
      end

      let(:input) do
        {foo: {name: "Jane", addresses: [{}]}}
      end

      it "produces errors for nested structs" do
        expect(result).to be_failing(
          addresses: {0 => {city: ["is missing", "must be a string"]}}
        )
      end
    end
  end

  context "valid hash" do
    let(:schema) do
      Dry::Schema.define do
        required(:foo).value(Dry.Struct(name: "string", email: "string"))
      end
    end

    let(:input) do
      {foo: {name: "John", email: "legit@email"}}
    end

    it "accepts valid input when it is a hash" do
      expect(schema.(input).errors.to_h).to eq({})
    end
  end

  context "struct with coercible attributes" do
    let(:struct) do
      Class.new(Dry::Struct) do
        attribute :date, Types::JSON::Date
        attribute :number, Types::JSON::Decimal
        attribute :string, Types::String
      end
    end

    let(:schema) do
      struct = self.struct

      Dry::Schema.Params do
        required(:foo).value(struct)
      end
    end

    it "coerces valid attributes" do
      result = schema.(foo: {date: "2023-09-07", number: "42", string: "Hi!"})

      expect(result).to be_success
      expect(result.to_h).to eq(foo: {date: Date.new(2023, 9, 7), number: BigDecimal("42"), string: "Hi!"})
    end

    it "reports errors only for invalid attributes" do
      expect(schema.(foo: {date: "00", number: "42", string: "Hi!"}).errors.to_h).to eq(
        foo: {date: ["must be a date"]}
      )

      expect(schema.(foo: {date: "2023-09-07", number: "42", string: 42}).errors.to_h).to eq(
        foo: {string: ["must be a string"]}
      )
    end

    context "as array elements" do
      let(:schema) do
        struct = self.struct

        Dry::Schema.Params do
          required(:foo).array(struct)
        end
      end

      it "coerces valid attributes of each element" do
        result = schema.(foo: [{date: "2023-09-07", number: "42", string: "Hi!"}])

        expect(result).to be_success
        expect(result.to_h).to eq(foo: [{date: Date.new(2023, 9, 7), number: BigDecimal("42"), string: "Hi!"}])
      end
    end

    context "with maybe" do
      let(:schema) do
        struct = self.struct

        Dry::Schema.Params do
          required(:foo).maybe(struct)
        end
      end

      it "accepts nil" do
        result = schema.(foo: nil)

        expect(result).to be_success
        expect(result.to_h).to eq(foo: nil)
      end
    end

    it "coerces valid attributes when other attributes are invalid" do
      result = schema.(foo: {date: "00", number: "42", string: "Hi!"})

      expect(result.to_h).to eq(foo: {date: "00", number: BigDecimal("42"), string: "Hi!"})
    end
  end

  context "struct with an array of coercible values" do
    let(:schema) do
      struct = Class.new(Dry::Struct) do
        attribute? :ids, Types::Array.of(Types::Params::Integer)
      end

      Dry::Schema.Params do
        optional(:filters).hash(struct)
      end
    end

    it "reports errors only for invalid elements" do
      expect(schema.(filters: {ids: %w[m 1]}).errors.to_h).to eq(
        filters: {ids: {0 => ["must be an integer"]}}
      )
    end
  end
end
