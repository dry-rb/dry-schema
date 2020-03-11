# frozen_string_literal: true

RSpec.describe "Defining base schema class" do
  subject(:schema) do
    Dry::Schema.define(parent: parent) do
      required(:email).filled
      required(:age).filled
    end
  end

  let(:parent) do
    Dry::Schema.define do
      configure do |config|
        config.messages.backend = :i18n
      end

      optional(:email).filled
      required(:name).filled

      before(:rule_applier) do |result|
        {name: "default"}.merge(result.to_h)
      end
    end
  end

  it "inherits rules" do
    expect(schema.(name: "", email: "jane@doe.org").errors).to eql(name: ["must be filled"], age: ["is missing"])
  end

  it "overrides parent rules" do
    expect(schema.(age: 21, name: "Jane").errors).to eql(email: ["is missing"])
  end

  it "inherits config" do
    expect(schema.config.messages.backend).to eql(:i18n)
  end

  context "when child schema defines config" do
    subject(:schema) do
      Dry::Schema.define(parent: parent) do
        config.messages.backend = :yaml
      end
    end

    it "overrides parent config" do
      expect(schema.config.messages.backend).to eql(:yaml)
    end
  end

  it "inherits callbacks" do
    result = schema.(age: 21)

    expect(result.errors).to eql(email: ["is missing"])
    expect(result.to_h).to eql(age: 21, name: "default")
  end

  it "does not mutate parent" do
    schema

    expect(parent.(name: "Jane")).to be_success
  end

  context "when child schema defines callback" do
    subject(:schema) do
      Dry::Schema.define(parent: parent) do
        before(:rule_applier) do |result|
          hash = result.to_h
          hash.merge(name: "new #{hash[:name]}")
        end
      end
    end

    it "stacks callbacks" do
      expect(schema.({}).to_h).to eql(name: "new default")
    end
  end
end
