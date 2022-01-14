# frozen_string_literal: true

RSpec.describe Dry::Schema::Result, "pattern matching" do
  subject(:result) { schema.(input) }

  context "basic match" do
    let(:input) { {"name" => "John"} }

    let(:schema) do
      Dry::Schema.Params { required(:name).filled(min_size?: 3) }
    end

    it "allows case analysis" do
      case result
      in { name: } => captured if name.eql?("John")
        expect(name).to eql("John")
        expect(captured).to eql(result)
      end
    end

    it "works in nested structure" do
      case [1, result]
      in [Integer => int, { name: "John"}]
        expect(int).to be(1)
      end
    end

    context "with monads" do
      before { Dry::Schema.load_extensions(:monads) }

      before do
        require "dry/monads"
      end

      it "supports nesting nicely" do
        case schema.("name" => "John").to_monad
        in Dry::Monads::Result::Success(name: "John") => captured
          expect(captured).to eql(result.to_monad)
          expect(captured).to be_success
        end

        case schema.("name" => "J").to_monad
        in Dry::Monads::Result::Failure(name:) => captured
          expect(captured).to be_failure
          expect(name).to eql("J")
        end
      end
    end
  end

  context "nested match" do
    let(:input) { {"name" => "John", "address" => {"city" => "London"}} }

    let(:schema) do
      Dry::Schema.Params do
        required(:name).filled
        required(:address).hash do
          required(:city).filled
        end
      end
    end

    it "is supported" do
      case result
      in address: { city: }
        expect(city).to eql("London")
      end
    end
  end
end
