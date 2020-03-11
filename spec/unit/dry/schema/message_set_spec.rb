# frozen_string_literal: true

require "dry/schema/message"
require "dry/schema/message_set"

RSpec.describe Dry::Schema::MessageSet do
  describe "#to_h" do
    def message_set_hash(*tuples, slice_length)
      Dry::Schema::MessageSet.new(
        tuples.each_slice(slice_length).map do |text, path, meta = {}|
          Dry::Schema::Message.new(
            text: text,
            path: path,
            meta: meta,
            input: nil,
            predicate: nil
          )
        end
      ).to_h
    end

    context "without meta" do
      def to_h(*tuples)
        message_set_hash(*tuples, 2)
      end

      it "builds an empty message hash" do
        expect(to_h).to eq({})
      end

      it "builds a shallow hash" do
        expect(
          to_h(
            "just a", %i[a]
          )
        ).to eq(
          a: ["just a"]
        )
      end

      it "builds a nested hash" do
        expect(
          to_h(
            "a then b", %i[a b]
          )
        ).to eq(
          a: {
            b: ["a then b"]
          }
        )
      end

      it "builds a mixed hash" do
        expect(
          to_h(
            "just a", %i[a],
            "a then b", %i[a b]
          )
        ).to eq(
          a: [
            ["just a"],
            {
              b: ["a then b"]
            }
          ]
        )
      end

      it "combines arrays" do
        expect(
          to_h(
            "just a", %i[a],
            "just a again", %i[a]
          )
        ).to eq(
          a: ["just a", "just a again"]
        )
      end

      it "combines arrays and hashes" do
        expect(
          to_h(
            "just a", %i[a],
            "a then b", %i[a b],
            "just a again", %i[a]
          )
        ).to eq(
          a: [
            ["just a", "just a again"],
            {
              b: ["a then b"]
            }
          ]
        )
      end

      it "builds a large hash" do
        expect(
          to_h(
            "just c", %i[c],
            "a then b", %i[a b],
            "just a", %i[a],
            "just b", %i[b],
            "a then b again", %i[a b],
            "just b again", %i[b],
            "just a again", %i[a],
            "a then b then c", %i[a b c]
          )
        ).to eq(
          a: [
            ["just a", "just a again"],
            {
              b: [
                ["a then b", "a then b again"],
                {
                  c: ["a then b then c"]
                }
              ]
            }
          ],
          b: ["just b", "just b again"],
          c: ["just c"]
        )
      end
    end

    context "with some meta" do
      def to_h(*tuples)
        message_set_hash(*tuples, 3)
      end

      it "builds a large hash" do
        expect(
          to_h(
            "just a", %i[a], {code: 123},
            "a then b", %i[a b], {},
            "just a again", %i[a], {code: 234},
            "a then b again", %i[a b], {code: 456},
            "just a again again", %i[a], {}
          )
        ).to eq(
          a: [
            [
              {
                text: "just a",
                code: 123
              },
              {
                text: "just a again",
                code: 234
              },
              "just a again again"
            ],
            {
              b: [
                "a then b",
                {
                  text: "a then b again",
                  code: 456
                }
              ]
            }
          ]
        )
      end
    end
  end
end
