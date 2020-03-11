# frozen_string_literal: true

RSpec.describe Dry::Schema::Processor do
  it_behaves_like "schema logic operators" do
    let(:schema_method) { :define }
  end

  context "with unexpected keys" do
    subject(:schema) do
      Dry::Schema.define do
        required(:user).hash(Test::UserSchema | Test::GuestSchema)
      end
    end

    before do
      Test::UserSchema = Dry::Schema.define do
        required(:login).filled(:string)
        required(:age).value(:integer)
      end

      Test::GuestSchema = Dry::Schema.define do
        required(:name).filled(:string)
      end
    end

    let(:result) do
      schema.(input)
    end

    context "with input matching left side" do
      let(:input) do
        {user: {foo: "bar", login: "jane", age: 36}}
      end

      it "uses a merged key-map to sanitize keys" do
        expect(result[:user].keys).to eql(%i[login age])
      end
    end

    context "with input matching right side" do
      let(:input) do
        {user: {foo: "bar", name: "jane"}}
      end

      it "uses a merged key-map to sanitize keys" do
        expect(result[:user].keys).to eql(%i[name])
      end
    end
  end
end
