# frozen_string_literal: true

require "dry/schema/message"
require "dry/schema/message/or/multi_path"

RSpec.describe Dry::Schema::Message::Or::MultiPath do
  def message(*path)
    Dry::Schema::Message.new(
      path: path,
      text: "is missing",
      predicate: :key?,
      input: {}
    )
  end

  describe "#to_h" do
    it "works with two arrays of messages" do
      result = described_class.new(
        [message(:foo, :bar)],
        [message(:foo, :baz)]
      ).to_h

      expect(result).to eq(
        {
          foo: {or: [{bar: ["is missing"]},
                     {baz: ["is missing"]}]}
        }
      )
    end

    it "works with an array of messages and a MultiPath" do
      result = described_class.new(
        [message(:foo, :bar)],
        described_class.new(
          [message(:foo, :baz)],
          [message(:foo, :qux)]
        )
      ).to_h

      expect(result).to eq(
        {
          foo: {or: [{bar: ["is missing"]},
                     {baz: ["is missing"]},
                     {qux: ["is missing"]}]}
        }
      )
    end

    it "works with a MultiPath and an array of messages" do
      result = described_class.new(
        described_class.new(
          [message(:foo, :baz)],
          [message(:foo, :qux)]
        ),
        [message(:foo, :bar)]
      ).to_h

      expect(result).to eq(
        {
          foo: {or: [{baz: ["is missing"]},
                     {qux: ["is missing"]},
                     {bar: ["is missing"]}]}
        }
      )
    end

    it "works with a MultiPath with a different root and an array of messages" do
      result = described_class.new(
        described_class.new(
          [message(:hello, :baz)],
          [message(:hello, :qux)]
        ),
        [message(:foo, :bar)]
      ).to_h

      expect(result).to eq(
        {
          or: [{hello: {or: [{baz: ["is missing"]},
                             {qux: ["is missing"]}]}},
               {foo: {bar: ["is missing"]}}]
        }
      )
    end

    it "does not work with an unknown message type" do
      expect { described_class.new(1, 2).to_h }
        .to raise_error(ArgumentError, /1 is of unknown type Integer/)
    end
  end
end
