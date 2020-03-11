# frozen_string_literal: true

require "dry/schema/result"

RSpec.describe Dry::Schema::Result, "#error?" do
  subject(:result) { schema.(input) }

  context "with a flat structure" do
    let(:schema) do
      Dry::Schema.Params { required(:name).filled }
    end

    context "when there is no error" do
      let(:input) do
        {name: "test"}
      end

      it "returns false" do
        expect(result.error?(:name)).to be(false)
      end
    end

    context "when there is an error" do
      let(:input) do
        {name: ""}
      end

      it "returns true" do
        expect(result.error?(:name)).to be(true)
      end
    end

    context "when spec is invalid" do
      let(:input) do
        {name: ""}
      end

      it "raises error" do
        expect { result.error?(Object.new) }
          .to raise_error(ArgumentError, "+spec+ must be either a Symbol, Array, Hash or a Path")
      end
    end

    context "when spec is a path already" do
      let(:input) do
        {name: ""}
      end

      it "returns true when there is an error" do
        expect(result.error?(Dry::Schema::Path[:name])).to be(true)
      end

      it "returns false when there is no error" do
        expect(result.error?(Dry::Schema::Path[:foo])).to be(false)
      end
    end
  end

  context "with a nested hash" do
    let(:schema) do
      Dry::Schema.Params do
        required(:user).hash do
          required(:address).hash do
            required(:street).filled(:string)
            optional(:zipcode).filled(:string)
          end
          optional(:phone).filled(:string)
        end
        optional(:address).filled(:string)
      end
    end

    context "when there is no error" do
      let(:input) do
        {user: {address: {street: "test"}}}
      end

      it "returns false for a hash spec" do
        expect(result.error?(user: {address: :street})).to be(false)
      end

      it "returns false for dot notation spec" do
        expect(result.error?("user.address.street")).to be(false)
      end
    end

    context "when there is an error under matching key but in another branch" do
      let(:input) do
        {user: {address: {street: "test"}}, address: ""}
      end

      it "returns false for a hash spec" do
        expect(result.error?(user: {address: :street})).to be(false)
      end

      it "returns false for dot notation spec" do
        expect(result.error?("user.address.street")).to be(false)
      end
    end

    context "when there are errors under keys from the same branch" do
      let(:input) do
        {user: {address: {street: ""}, phone: ""}}
      end

      it "returns true for a hash spec" do
        expect(result.error?(user: {address: :street})).to be(true)
        expect(result.error?(user: :phone)).to be(true)
      end

      it "returns true for dot notation spec" do
        expect(result.error?("user.address.street")).to be(true)
        expect(result.error?("user.phone")).to be(true)
      end

      it "returns false for a hash spec on a valid key" do
        expect(result.error?(user: :zipcode)).to be(false)
      end

      it "returns false for dot notation spec on a valid key" do
        expect(result.error?("user.address.zipcode")).to be(false)
      end
    end

    context "when there is an error under the last key" do
      let(:input) do
        {user: {address: {street: ""}}}
      end

      it "returns true for a hash spec" do
        expect(result.error?(user: {address: :street})).to be(true)
      end

      it "returns true for dot notation spec" do
        expect(result.error?("user.address.street")).to be(true)
      end
    end

    context "when there is an error under one of the intermediate keys" do
      let(:input) do
        {user: {address: nil}}
      end

      it "returns true for a hash spec with the error" do
        expect(result.error?(user: :address)).to be(true)
      end

      it "returns true for dot notation spec with the error" do
        expect(result.error?("user.address")).to be(true)
      end

      it "returns false for a hash spec with no error" do
        expect(result.error?(user: {address: :street})).to be(false)
      end

      it "returns false for dot notation spec with no error" do
        expect(result.error?("user.address.street")).to be(false)
      end
    end
  end

  context "with an array" do
    let(:schema) do
      Dry::Schema.Params do
        required(:tags).array(:str?)
      end
    end

    context "when there is no error" do
      let(:input) do
        {tags: %w[foo bar]}
      end

      it "returns false for symbol key spec" do
        expect(result.error?(:tags)).to be(false)
      end

      it "returns false for a path with index" do
        expect(result.error?([:tags, 0])).to be(false)
        expect(result.error?([:tags, 1])).to be(false)
      end
    end

    context "when there is an error under key" do
      let(:input) do
        {tags: nil}
      end

      it "returns true for symbol key spec" do
        expect(result.error?(:tags)).to be(true)
      end

      it "returns false for a path with index" do
        expect(result.error?([:tags, 0])).to be(false)
        expect(result.error?([:tags, 1])).to be(false)
      end
    end

    context "when there is an error under one of the indices" do
      let(:input) do
        {tags: ["foo", 312]}
      end

      it "returns true for symbol key spec" do
        expect(result.error?(:tags)).to be(true)
      end

      it "returns true for a path with index with the error" do
        expect(result.error?([:tags, 1])).to be(true)
      end

      it "returns false for a path with index with no error" do
        expect(result.error?([:tags, 0])).to be(false)
      end
    end
  end
end
