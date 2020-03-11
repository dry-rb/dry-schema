# frozen_string_literal: true

require "dry/schema/macros/required"

RSpec.describe Dry::Schema::Macros::Required do
  subject(:macro) do
    Dry::Schema::Macros::Required.new(name: :email)
  end

  describe "#to_rule" do
    it "builds a valid rule without additional predicates" do
      rule = macro.to_rule

      expect(rule.(email: "jane@doe.org")).to be_success
      expect(rule.(imejl: "jane@doe.org")).to be_failure
    end

    it "builds a valid rule with additional predicates" do
      rule = macro.value(:str?, size?: 2..20).to_rule

      expect(rule.(email: "jane@doe.org")).to be_success

      expect(rule.(imejl: "jane@doe.org")).to be_failure
      expect(rule.(email: "j")).to be_failure
      expect(rule.(email: "jane@doe.org" * 2)).to be_failure
    end

    it "builds a valid rule with predicates defined in a block" do
      rule = macro.value { str? & size?(2..20) }.to_rule

      expect(rule.(email: "jane@doe.org")).to be_success

      expect(rule.(imejl: "jane@doe.org")).to be_failure
      expect(rule.(email: "j")).to be_failure
      expect(rule.(email: "jane@doe.org" * 2)).to be_failure
    end
  end

  describe "#filled" do
    it "builds a rule with :filled? predicate without additional predicates" do
      rule = macro.filled.to_rule

      expect(rule.(email: "jane@doe.org")).to be_success
      expect(rule.(email: "")).to be_failure
      expect(rule.(email: nil)).to be_failure
    end

    it "builds a valid rule with additional predicates" do
      rule = macro.filled(:str?).to_rule

      expect(rule.(email: "jane@doe.org")).to be_success
      expect(rule.(email: "")).to be_failure
      expect(rule.(email: 312)).to be_failure
    end

    it "builds a valid rule with additional predicates defined in a block" do
      rule = macro.filled(:str?) { size?(4) }.to_rule

      expect(rule.(email: "jane")).to be_success
      expect(rule.(email: "joe")).to be_failure
      expect(rule.(email: 312)).to be_failure
    end
  end

  describe "#each" do
    it "builds a rule with predicates applied to array elements" do
      rule = macro.each(:str?).to_rule

      expect(rule.(email: %w[foo bar])).to be_success
      expect(rule.(email: [1, "bar"])).to be_failure
    end
  end

  describe "chaining macros" do
    it "merges rules from chain-method calls" do
      rule = macro.filled(:str?).value(size?: 2..4).to_rule

      expect(rule.(email: "jane")).to be_success
      expect(rule.(email: "jeremy")).to be_failure
    end
  end
end
