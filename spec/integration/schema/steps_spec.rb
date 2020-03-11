# frozen_string_literal: true

RSpec.describe Dry::Schema, "callbacks" do
  context "top-level" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:name).maybe(:str?)
        required(:date).maybe(:date?)

        before(:key_coercer) do |result|
          {name: "default"}.merge(result.to_h)
        end

        after(:rule_applier) do |result|
          result.to_h.compact
        end
      end
    end

    it "calls callbacks" do
      expect(schema.(date: nil).to_h).to eql(name: "default")
    end
  end

  context "under a nested schema" do
    subject(:schema) do
      Dry::Schema.define do
        required(:account).hash do
          required(:user).hash(Test::UserSchema)
        end
      end
    end

    before do
      Test::UserSchema = Dry::Schema.define do
        optional(:name).maybe(:string)
        required(:date).maybe(:date)

        before(:key_coercer) do |result|
          {name: "default"}.merge(result.to_h)
        end

        after(:rule_applier) do |result|
          result.to_h.compact
        end
      end
    end

    it "calls callbacks" do
      expect(schema.(account: {user: {date: nil}}).to_h)
        .to eql(account: {user: {name: "default"}})
    end
  end

  context "under a nested schema in an array" do
    subject(:schema) do
      Dry::Schema.define do
        required(:accounts).array(:hash) do
          required(:user).hash(Test::UserSchema)
        end
      end
    end

    before do
      Test::UserSchema = Dry::Schema.define do
        optional(:name).maybe(:string)
        required(:date).maybe(:date)

        before(:key_coercer) do |result|
          {name: "default"}.merge(result.to_h)
        end

        after(:rule_applier) do |result|
          result.to_h.compact
        end
      end
    end

    it "calls callbacks" do
      pending "not implemented yet"

      expect(schema.(accounts: [{user: {date: nil}}]).to_h)
        .to eql(accounts: [{user: {name: "default"}}])
    end
  end

  context "invalid step name" do
    it "raises error" do
      expect {
        Dry::Schema.define do
          before(:oops) {}
          required(:user).value(:hash)
        end
      }.to raise_error(ArgumentError, /oops/)
    end
  end
end
