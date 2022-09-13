# frozen_string_literal: true

RSpec.describe "Macros #maybe" do
  describe "with no args" do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).maybe
      end
    end

    it "generates nil? | filled? rule" do
      expect { schema }.to raise_error(ArgumentError)
    end
  end

  describe "with a type spec" do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).maybe(:string, format?: /@/)
      end
    end

    it "generates nil? | str? rule" do
      expect(schema.(email: nil)).to be_success
      expect(schema.(email: "jane@doe.org")).to be_success
      expect(schema.(email: "jane").errors).to eql(email: ["is in invalid format"])
    end
  end

  describe "with a predicate with args" do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe(min_size?: 3)
      end
    end

    it "generates nil? | (filled? & min_size?) rule" do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: "jane").messages).to be_empty

      expect(schema.(name: "xy").messages).to eql(
        name: ["size cannot be less than 3"]
      )
    end
  end

  describe "with a block" do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe { str? & min_size?(3) }
      end
    end

    it "generates nil? | (str? & min_size?) rule" do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: "jane").messages).to be_empty

      expect(schema.(name: "xy").messages).to eql(
        name: ["size cannot be less than 3"]
      )
    end
  end

  describe "with an optional key and a block with schema" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:employee).maybe(:hash).maybe(:hash?) do
          schema do
            required(:id).filled(:string)
          end
        end
      end
    end

    it "passes when input is valid" do
      expect(schema.(employee: {id: "1"})).to be_success
    end

    it "passes when key is missing" do
      expect(schema.({})).to be_success
    end

    it "passes when value is nil" do
      expect(schema.(employee: nil)).to be_success
    end

    it "fails when value for nested schema is invalid" do
      expect(schema.(employee: {id: 1}).messages).to eql(
        employee: {id: ["must be a string"]}
      )
    end
  end

  describe "with a predicate and a block" do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe(:str?) { min_size?(3) }
      end
    end

    it "generates nil? | (str? & min_size?) rule" do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: "jane").messages).to be_empty

      expect(schema.(name: "xy").messages).to eql(
        name: ["size cannot be less than 3"]
      )
    end
  end

  context "with a nested hash" do
    subject(:schema) do
      Dry::Schema.define do
        required(:song).maybe(:hash) do
          required(:title).filled
          required(:author).filled
        end
      end
    end

    it "passes when valid" do
      song = {title: "World", author: "Joe"}

      expect(schema.(song: song)).to be_success
    end

    it "fails when not valid" do
      song = {title: nil, author: "Jane"}

      expect(schema.(song: song).messages).to eql(
        song: {title: ["must be filled"]}
      )
    end

    it "passes when nil" do
      expect(schema.(song: nil)).to be_success
    end
  end

  context "with a nested schema" do
    inner_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    schema = Dry::Schema.define do
      required(:user).maybe(:hash, inner_schema)
    end

    it "passes when valid" do
      expect(schema.(user: {name: "John"})).to be_success
    end

    it "fails when not valid" do
      expect(schema.(user: {name: 1}).errors.to_h).to eq(user: {name: ["must be a string"]})
    end
  end

  context "with an array with nested schema" do
    inner_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    schema = Dry::Schema.define do
      required(:users).maybe(:array).each(inner_schema)
    end

    it "passes when valid" do
      expect(schema.(users: [{name: "John"}])).to be_success
    end

    it "fails when not valid" do
      expect(schema.(users: [{name: 1}]).errors.to_h).to eq(users: {0 => {name: ["must be a string"]}})
    end
  end

  describe "nested into further DSLs" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).maybe(:array).each do
          maybe(:array).each do
            maybe(Types::Strict::String)
          end
        end
      end
    end

    it "passes when valid" do
      expect(schema.call(foo: [["bar"]])).to be_success
      expect(schema.call(foo: [])).to be_success
      expect(schema.call(foo: [nil])).to be_success
      expect(schema.call(foo: [[nil]])).to be_success
    end

    it "fails when invalid" do
      expect(schema.call(foo: 1).messages).to eql(foo: ["must be an array"])
      expect(schema.call(foo: [1]).messages).to eql(foo: {0 => ["must be an array"]})
      expect(schema.call(foo: [[1]]).messages).to eql(foo: {0 => {0 => ["must be a string"]}})
    end
  end
end
