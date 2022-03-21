# frozen_string_literal: true

RSpec.describe Dry::Schema, "OR messages" do
  context "with two predicates" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | int? }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: 321)).to be_success
    end

    it "provides OR error message for invalid input where all both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be an integer"])
    end
  end

  context "with three predicates" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | int? | bool? }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: 321)).to be_success
      expect(schema.(foo: true)).to be_success
    end

    it "provides OR error message for invalid input where all sides failed" do
      expect(schema.(foo: []).errors.to_h).to eql(foo: ["must be a string or must be an integer or must be boolean"])
    end
  end

  context "with a predicate and a conjunction of predicates" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | (int? & gt?(18)) }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: 321)).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be an integer"])
    end

    it "provides error messages for invalid input where right side failed" do
      expect(schema.(foo: 17).errors).to eql(foo: ["must be a string or must be greater than 18"])
    end
  end

  context "with a predicate and an each operation" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | value(:array?).each(:int?) }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: [1, 2, 3])).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: {}).errors).to eql(foo: ["must be a string or must be an array"])
    end

    it "provides error messages for invalid input where right side failed" do
      expect(schema.(foo: %w[1 2 3]).errors).to eql(
        foo: {
          0 => ["must be an integer"],
          1 => ["must be an integer"],
          2 => ["must be an integer"]
        }
      )
    end
  end

  context "with a predicate and a schema" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | hash { required(:bar).filled } }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: {bar: "baz"})).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be a hash"])
    end

    it "provides error messages for invalid input where right side rules failed" do
      expect(schema.(foo: {bar: ""}).errors).to eql(foo: {bar: ["must be filled"]})
    end
  end

  context "with two schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
    end

    it "provides error messages for invalid input where both sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(user: {or: [{name: ["is missing"]}, {nickname: ["is missing"]}]})
    end
  end

  context "with three schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
      required(:surname).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    email_schema = Dry::Schema.define do
      required(:email).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema | email_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John", surname: "Smith"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
      expect(schema.(user: {email: "test@example.com"})).to be_success
    end

    it "provides error messages for invalid input where both sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(user: {or: [{name: ["is missing"], surname: ["is missing"]}, {nickname: ["is missing"]}, email: ["is missing"]]})
    end
  end

  context "with multiple schemas and a single field" do
    first_schema = Dry::Schema.define do
      required(:type).filled(Types::String.enum(["1"]))
    end
    second_schema = Dry::Schema.define do
      required(:type).filled(Types::String.enum(["2"]))
    end
    third_schema = Dry::Schema.define do
      required(:type).filled(Types::String.enum(["3"]))
    end
    fourth_schema = Dry::Schema.define do
      required(:type).filled(Types::String.enum(["4"]))
    end
    main_schema = Dry::Schema.define do
      required(:t).hash(first_schema | second_schema | third_schema | fourth_schema)
    end

    it "returns success for valid input" do
      expect(main_schema.(t: { type: "1" })).to be_success
      expect(main_schema.(t: { type: "2" })).to be_success
      expect(main_schema.(t: { type: "3" })).to be_success
      expect(main_schema.(t: { type: "4" })).to be_success
    end

    it "provides error messages for invalid input where both sides failed" do
      expect(main_schema.(t: { type: "15" }).errors.to_h).to eql(t: {or: [{type: ["must be one of: 1 or must be one of: 2 or must be one of: 3 or must be one of: 4"] }] })
    end
  end

  context "with complex multiple schemas with inner nestings" do
    first_schema = Dry::Schema.define do
      required(:event).filled(Types::String.enum("1"))
      required(:name).filled(:string)
      required(:timestamp).filled(:time)
    end

    second_schema = Dry::Schema.define do
      required(:event).filled(Types::String.enum("2"))
      required(:name).filled(:string)
    end

    third_schema = Dry::Schema.define do
      required(:event).filled(Types::String.enum("3"))
      required(:timestamp).filled(:time)
    end

    fourth_schema = Dry::Schema.define do
      required(:event).filled(Types::String.enum("4"))
      required(:timestamp).filled(:time)
    end

    main_schema = Dry::Schema.define do
      required(:events).value(:array).each do
        hash? & (first_schema | second_schema | third_schema | fourth_schema)
      end
    end

    it "returns success for valid input" do
      expect(main_schema.(events: [])).to be_success
      expect(main_schema.(events: [{event: "1", name: "Hello", timestamp: "2021-11-30T16:22:58+00:00"}])).to be_success
      expect(main_schema.(events: [{event: "2", name: "Hello"}])).to be_success
      expect(main_schema.(events: [{event: "4", name: "Hello", timestamp: Time.now}])).to be_success
    end

    it "provides error messages for invalid input where both sides failed" do
      expect(
        main_schema.(events: [{event: "1", timestamp: Time.now}]).errors.to_h
      ).to(
        eql(
          events: {
            0 => {
                or: [
                   {:event=>["must be one of: 1"], :name=>["is missing"]},
                   {:event=>["must be one of: 2"]},
                   {:event=>["must be one of: 3"]},
                   {:event=>["must be one of: 4"]}
                ]
            }
          }
        )
      )

      expect(
        main_schema.(events: [{event: "4"}]).errors.to_h
      ).to(
        eql(
          events: {
            0 => {
              or: [
                {:event=>["must be one of: 1"], :name=>["is missing"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 2"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 3"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 4"], :timestamp=>["is missing"]}
              ]
            }
          }
        )
      )
      expect(
        main_schema.(events: [{event: "5"}]).errors.to_h
      ).to(
        eql(
          events: {
            0 => {
              or: [
                {:event=>["must be one of: 1"], :name=>["is missing"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 2"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 3"], :timestamp=>["is missing"]},
                {:event=>["must be one of: 4"], :timestamp=>["is missing"]}
              ]
            }
          }
        )
      )
    end
  end
end