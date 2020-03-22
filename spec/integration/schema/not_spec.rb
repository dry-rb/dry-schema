# frozen_string_literal: true

RSpec.describe "Schema with negated rules" do
  describe "with a negated predicate" do
    subject(:schema) do
      Dry::Schema.define do
        required(:tags).value(:array) { !empty? }
      end
    end

    it "passes with valid input" do
      expect(schema.(tags: %w[a b c])).to be_success
    end

    it "fails with invalid input" do
      expect(schema.(tags: []).errors).to eql(tags: ["cannot be empty"])
    end
  end

  describe "with a negated predicate composed with another predicate" do
    subject(:schema) do
      Dry::Schema.define do
        required(:tags).value(:array) { !empty? & size?(3) }
      end
    end

    it "passes with valid input" do
      expect(schema.(tags: %w[a b c])).to be_success
    end

    it "fails with invalid input" do
      expect(schema.(tags: []).errors).to eql(tags: ["cannot be empty"])
      expect(schema.(tags: %w[a b]).errors).to eql(tags: ["size must be 3"])
    end
  end
end
