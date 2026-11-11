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
end
