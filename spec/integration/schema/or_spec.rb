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
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    alias_schema = Dry::Schema.define do
      required(:alias).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema | alias_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
      expect(schema.(user: {alias: "Slick"})).to be_success
    end

    it "provides error messages for invalid input where all sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(
        {
          user: {or: [{name: ["is missing"]},
                      {nickname: ["is missing"]},
                      {alias: ["is missing"]}]}
        }
      )
    end
  end

  context "with four schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    alias_schema = Dry::Schema.define do
      required(:alias).filled(:string)
    end

    favorite_food_schema = Dry::Schema.define do
      required(:favorite_food).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema | alias_schema | favorite_food_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
      expect(schema.(user: {alias: "Slick"})).to be_success
      expect(schema.(user: {favorite_food: "pizza"})).to be_success
    end

    it "provides error messages for invalid input where all sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(
        {
          user: {or: [{name: ["is missing"]},
                      {nickname: ["is missing"]},
                      {alias: ["is missing"]},
                      {favorite_food: ["is missing"]}]}
        }
      )
    end
  end

  context "a very complicated schema" do
    foo_schema_base = Dry::Schema.JSON do
      required(:type).filled(:string)
    end

    foo_1_value_schema = Dry::Schema.JSON do
      required(:timestamp).filled(:date_time)
    end

    foo_schema_1 = Dry::Schema.JSON(parent: [foo_schema_base]) do
      required(:type).filled(:string, included_in?: %w[foo_1])
      required(:value).filled(:array).array(:hash, foo_1_value_schema)
    end

    foo_schema_2 = Dry::Schema.JSON(parent: [foo_schema_base]) do
      required(:type).filled(:string, included_in?: %w[foo_2])
      required(:value).filled(:array).value(array[:date_time])
    end

    foo_schema_3 = Dry::Schema.JSON(parent: [foo_schema_base]) do
      required(:type).filled(:string, included_in?: %w[foo_3])
      required(:value).hash do
        required(:left).filled(:date_time)
        required(:right).filled(:date_time)
      end
    end

    foo_schema_4 = Dry::Schema.JSON(parent: [foo_schema_base]) do
      required(:type).filled(:string, included_in?: %w[foo_4])
      required(:value).hash do
        required(:top).filled(:string)
        required(:bottom).filled(:string)
      end
    end

    foo_schema = [
      foo_schema_1,
      foo_schema_2,
      foo_schema_3,
      foo_schema_4
    ].reduce(:|)

    foo_schema_extra = Dry::Schema.JSON(parent: [foo_schema_base]) do
      required(:type).filled(:string, included_in?: %w[foo_extra])
      required(:value).filled(:string, format?: /foo/)
    end

    bar_schema_base = Dry::Schema.JSON do
      required(:type).filled(:string)
    end

    arg_schema = Dry::Schema.JSON do
      required(:value).value { int? | (filled? & str?) }
    end

    baz_schema = Dry::Schema.JSON do
      required(:foos).array(:hash, foo_schema_extra | foo_schema)
      optional(:args).filled(:array).array(:hash, arg_schema)
    end

    bar_schema_1 = Dry::Schema.JSON(parent: [bar_schema_base, baz_schema]) do
      required(:type).filled(:string, included_in?: %w[bar_1])
    end

    bar_schema_2 = Dry::Schema.JSON(parent: [bar_schema_base]) do
      required(:type).filled(:string, included_in?: %w[bar_2])
      required(:bazes).array(:hash, baz_schema)
    end

    bar_schema_3 = Dry::Schema.JSON(parent: [bar_schema_base, baz_schema]) do
      required(:type).filled(:string, included_in?: %w[bar_3])
    end

    bar_schema = [bar_schema_1, bar_schema_2, bar_schema_3].reduce(:|)

    schema = Dry::Schema.JSON do
      required(:bars).array(:hash, bar_schema)
    end

    it "can succeed" do
      expect(
        schema.(
          bars: [
            {
              type: "bar_1",
              foos: [
                {
                  type: "foo_extra",
                  id: "id",
                  value: "foobar"
                }
              ]
            }
          ]
        )
      ).to be_success

      expect(
        schema.(
          bars: [
            {
              type: "bar_1",
              foos: [
                {
                  type: "foo_1",
                  id: "id",
                  value: [{timestamp: Time.now.iso8601}]
                }
              ]
            }
          ]
        )
      ).to be_success

      expect(
        schema.(
          bars: [
            {
              type: "bar_1",
              foos: [
                {
                  type: "foo_2",
                  id: "id",
                  value: [Time.now.iso8601]
                }
              ]
            }
          ]
        )
      ).to be_success

      expect(
        schema.(
          bars: [
            {
              type: "bar_2",
              bazes: [
                {
                  foos: [
                    {
                      type: "foo_3",
                      id: "id",
                      value: {
                        left: Time.now.iso8601,
                        right: Time.now.iso8601
                      }
                    }
                  ]
                }
              ]
            }
          ]
        )
      ).to be_success
    end

    it "provides error messages for a failure" do
      expect(
        schema
          .(bars: [{type: "bar_1", foos: [{type: "foo_extra", id: "id"}]}])
          .errors
          .to_h
      ).to eq(
        bars: {
          0 => {
            or: [
              {
                bars: {
                  0 => {
                    foos: {
                      0 => {
                        or: [
                          {value: ["is missing"]},
                          {
                            type: ["must be one of: foo_1"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_2"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_3"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_4"],
                            value: ["is missing"]
                          }
                        ]
                      }
                    }
                  }
                }
              },
              {bazes: ["is missing"], type: ["must be one of: bar_2"]},
              {
                bars: {
                  0 => {
                    foos: {
                      0 => {
                        or: [
                          {value: ["is missing"]},
                          {
                            type: ["must be one of: foo_1"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_2"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_3"],
                            value: ["is missing"]
                          },
                          {
                            type: ["must be one of: foo_4"],
                            value: ["is missing"]
                          }
                        ]
                      }
                    }
                  }
                },
                type: ["must be one of: bar_3"]
              }
            ]
          }
        }
      )

      expect(
        schema
          .(
            bars: [
              {
                type: "bar_1",
                foos: [{type: "foo_extra", id: "id", value: "foobar"}],
                args: [{value: false}]
              }
            ]
          )
          .errors
          .to_h
      ).to eq(
        bars: {
          0 => {
            or: [
              {args: {value: ["must be an integer or must be a string"]}},
              {bazes: ["is missing"], type: ["must be one of: bar_2"]},
              {
                args: {
                  value: ["must be an integer or must be a string"]
                },
                type: ["must be one of: bar_3"]
              }
            ]
          }
        }
      )
    end
  end
end
