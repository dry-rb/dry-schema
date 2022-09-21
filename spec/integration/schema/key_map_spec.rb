# frozen_string_literal: true

RSpec.describe Dry::Schema, "#key_map" do
  context "with an inherited schema" do
    it "copies key map from the parent and includes new keys from child" do
      parent = Dry::Schema.define do
        required(:name).filled(:string)
      end

      child = Dry::Schema.define(parent: parent) do
        required(:email).filled(:string)
      end

      expect(child.key_map.map(&:name).sort).to eql(%i[email name])
    end
  end

  context "with an inherited params" do
    it "copies key map from the parent and includes new keys from child" do
      parent = Dry::Schema.Params do
        required(:name).filled(:string)
      end

      child = Dry::Schema.Params(parent: parent) do
        required(:email).filled(:string)
      end

      expect(child.key_map.map(&:name).sort).to eql(%w[email name])
    end
  end
end
