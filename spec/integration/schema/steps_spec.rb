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

  context "with callbacks in main schema and nested schemas" do
    subject(:schema) do
      Dry::Schema.define do
        required(:account).schema do
          required(:name).filled(:string)

          before(:key_coercer) do |result|
            result.to_h.transform_keys(&:downcase)
          end
        end

        required(:email).schema do
          required(:address).schema do
            required(:local_part).filled(:string)
            required(:domain).filled(:string)

            before(:key_coercer) do |result|
              result.to_h.transform_keys { |key| key.to_s.squeeze.to_sym }
            end
          end

          before(:key_coercer) do |result|
            result.to_h.transform_keys(&:succ)
          end
        end

        before(:key_coercer) do |result|
          result.to_h.transform_keys(&:to_sym)
        end
      end
    end

    specify do
      input = {
        "account" => {
          NaMe: "ojab"
        },
        "email" => {
          addresr: {
            loocall_part: "not_ojab",
            dooooooomain: "example.org"
          }
        }
      }
      expect(schema.(input).to_h).to eql(
        account: {name: "ojab"}, email: {address: {local_part: "not_ojab", domain: "example.org"}}
      )
    end
  end

  context "when schema with callbacks is reused" do
    let(:first_schema) do
      local_nested_schema = nested_schema
      Dry::Schema.define do
        required(:a).filled(local_nested_schema)
      end
    end

    let(:second_schema) do
      local_nested_schema = nested_schema

      Dry::Schema.define do
        required(:b).schema do
          required(:c).filled(local_nested_schema)

          before(:key_coercer) do |result|
            result.to_h.transform_keys { |_key| :c }
          end
        end
      end
    end

    let(:nested_schema) do
      Dry::Schema.define do
        required(:name).filled(:string)

        before(:key_coercer) { |result| result.to_h.transform_keys(&:to_sym) }
      end
    end

    it "correctly handles reused schemas" do
      expect(first_schema.(a: {"name" => "ojab"}).to_h).to eql(a: {name: "ojab"})
      expect(second_schema.(b: {foo: {"name" => "ojab"}}).to_h).to eql(b: {c: {name: "ojab"}})
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
