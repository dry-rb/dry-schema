# frozen_string_literal: true

RSpec.describe Dry::Schema, "key searching algorithm" do
  it "works properly with keys that are prefixes of other keys" do
    schema = Dry::Schema.define do
      config.validate_keys = true

      required(:a).filled(:string)
      required(:fooA).filled(:string)
      required(:foo).array(:hash) do
        required(:bar).filled(:string)
      end
    end

    expect(schema.(a: "string", fooA: "string", foo: "string").errors.to_h)
      .to eql({foo: ["must be an array"]})
  end
end
