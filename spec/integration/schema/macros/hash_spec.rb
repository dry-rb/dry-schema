# frozen_string_literal: true

RSpec.describe "Macros #hash" do
  subject(:schema) do
    Dry::Schema.define do
      required(:foo).hash do
        required(:bar).value(:string)
      end
    end
  end

  context "with valid input" do
    let(:input) do
      {foo: {bar: "valid"}}
    end

    it "is successful" do
      expect(result).to be_successful
    end
  end

  context "with invalid input" do
    let(:input) do
      {foo: {bar: 312}}
    end

    it "is not successful" do
      expect(result).to be_failing(bar: ["must be a string"])
    end
  end

  context "with invalid input type" do
    let(:input) do
      {foo: nil}
    end

    it "is not successful" do
      expect(result).to be_failing(["must be a hash"])
    end
  end

  context "with hash schema" do
    let(:hash_schema) do
      Types::Hash.schema(name: "string")
    end

    subject(:schema) do
      hash_schema = self.hash_schema

      Dry::Schema.define do
        required(:foo).hash(hash_schema)
      end
    end

    context "and a block" do
      subject(:schema) do
        hash_schema = self.hash_schema

        Dry::Schema.define do
          required(:foo).hash(hash_schema) do
            required(:email).value(:string)
          end
        end
      end

      let(:input) { {foo: {name: "John"}} }

      it "combines schemas" do
        expect(result).to be_failing(email: ["is missing", "must be a string"])
      end
    end

    context "and a predicate" do
      subject(:schema) do
        hash_schema = self.hash_schema

        Dry::Schema.define do
          required(:foo).hash(hash_schema, :filled?)
        end
      end

      let(:input) { {foo: {}} }

      it "adds predicates" do
        expect(result).to be_failing(["must be filled"])
      end
    end

    context "with coercible types" do
      let(:hash_schema) do
        Types::Hash.schema(age: "params.integer")
      end

      let(:input) { {foo: {age: "39"}} }

      specify do
        expect(result.to_h).to eql(foo: {age: 39})
      end
    end

    context 'with custom coercible type' do
 
      subject(:schema) do
        ExpirationDate = Types::DateTime.constructor { |value| value.to_time.round.to_datetime }
        Dry::Schema.Params do
          required(:unnested_dated).value(ExpirationDate)
          required(:foo).hash do
            required(:bar).hash do
              required(:nested_date).value(ExpirationDate)
            end
          end
        end
      end

      let(:input) { {foo: {nested_date: '2021-11-11T00:00:00+00:00'}, unnested_date: '2021-11-11T00:00:00+00:00'  } }

      specify do
        expect(result).to be_successful
        expect(result.to_h).to eql(foo: {date:  DateTime.new(2021, 11, 11) }, unnested_data: DateTime.new(2021, 11, 11))
      end
    end

    context "constrained type" do
      let(:hash_schema) do
        Types::Hash.schema({}).constrained([:filled])
      end

      let(:input) { {foo: {}} }

      it "adds predicates" do
        expect(result).to be_failing(["must be filled"])
      end
    end
  end
end
