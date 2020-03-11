# frozen_string_literal: true

RSpec.describe Dry::Schema::Result do
  before { Dry::Schema.load_extensions(:monads) }

  let(:schema) { Dry::Schema.define { required(:name).filled(:str?, size?: 2..4) } }

  let(:result) { schema.(input) }

  context "interface" do
    let(:input) { {} }

    it "responds to #to_monad" do
      expect(result).to respond_to(:to_monad)
    end
  end

  context "with valid input" do
    let(:input) { {name: "Jane"} }

    describe "#to_monad" do
      it "returns a Success value" do
        monad = result.to_monad

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_success
        expect(monad.value!).to be(result)
      end
    end
  end

  context "with invalid input" do
    let(:input) { {name: ""} }

    describe "#to_monad" do
      it "wraps Reuslt with Failure constructor" do
        monad = result.to_monad

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_failure
        expect(monad.failure).to be(result)
      end
    end
  end
end
