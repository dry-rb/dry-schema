# frozen_string_literal: true

RSpec.describe Dry::Schema, "pre-coercion input rules" do
  context "coercion" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:date).filter(format?: /\d{4}-\d{2}-\d{2}/).filled(:date, :date?, gt?: Date.new(2019, 1, 23))
        required(:other).value(:integer, gt?: 18)
      end
    end

    it "skips coercion when filter rules failed" do
      expect(schema.(date: "2010-1-23", other: "19").to_h).to eql(date: "2010-1-23", other: 19)
    end
  end

  context "with required key and filled" do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).filter(format?: /\d+/).filled(:integer, gt?: 18)
        required(:login).maybe(size?: 2..12)
      end
    end

    it "uses pre-coercion rules" do
      expect(schema.call(age: "foo", login: "jane").errors.to_h)
        .to include(age: ["is in invalid format"])
    end

    it "merges results" do
      expect(schema.call(age: "foo", login: "j").errors)
        .to eql(age: ["is in invalid format"], login: ["length must be within 2 - 12"])
    end
  end

  context "with required key and maybe" do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).filter(format?: /\d+/).maybe(:integer, gt?: 18)
      end
    end

    it "uses pre-coercion rules" do
      expect(schema.call(age: "foo").errors).to eql(age: ["is in invalid format"])
    end
  end

  context "with optional keys" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:age).filter(format?: /\d+/).filled(:integer, gt?: 18)
      end
    end

    it "uses pre-coercion rules" do
      expect(schema.call(age: "foo").errors).to eql(age: ["is in invalid format"])
    end

    it "skips pre-coercion when key is missing" do
      expect(schema.call({}).errors).to be_empty
    end
  end

  context "with keys in a nested hash" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:transfer).hash do
          required(:first_date).filter(format?: /\A\d{4}-\d{2}-\d{2}\z/).value(:date)
          optional(:last_date).filter(format?: /\A\d{4}-\d{2}-\d{2}\z/).value(:date)
          optional(:amount).value(:integer)
        end
      end
    end

    it "coerces sibling values when a nested filter fails" do
      result = schema.call(transfer: {first_date: "2025-01-01", last_date: "", amount: "10"})

      expect(result.errors.to_h).to eql(transfer: {last_date: ["is in invalid format"]})
      expect(result.to_h).to eql(transfer: {first_date: Date.new(2025, 1, 1), last_date: "", amount: 10})
    end

    it "does not coerce values that failed a nested filter" do
      result = schema.call(transfer: {first_date: "2025-01-01", last_date: "2025/01/02"})

      expect(result.errors.to_h).to eql(transfer: {last_date: ["is in invalid format"]})
      expect(result.to_h).to eql(transfer: {first_date: Date.new(2025, 1, 1), last_date: "2025/01/02"})
    end
  end

  context "with keys in a deeply nested hash" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:outer).hash do
          required(:inner).hash do
            required(:date).filter(format?: /\A\d{4}-\d{2}-\d{2}\z/).value(:date)
            required(:amount).value(:integer)
          end
          required(:count).value(:integer)
        end
      end
    end

    it "coerces values around the failed filter" do
      result = schema.call(outer: {inner: {date: "2025/01/02", amount: "5"}, count: "3"})

      expect(result.errors.to_h).to eql(outer: {inner: {date: ["is in invalid format"]}})
      expect(result.to_h).to eql(outer: {inner: {date: "2025/01/02", amount: 5}, count: 3})
    end
  end
end
