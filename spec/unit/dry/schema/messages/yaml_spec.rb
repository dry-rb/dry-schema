# frozen_string_literal: true

require "dry/schema/messages/yaml"
require "dry/schema/messages/template"

RSpec.describe Dry::Schema::Messages::YAML do
  subject(:messages) do
    Dry::Schema::Messages::YAML.build
  end

  describe "#[]" do
    context "with default config" do
      it "returns text and optional meta" do
        template, meta = messages[:filled?, path: [:name]]

        expect(template.()).to eql("must be filled")
        expect(meta).to eql({})
      end
    end

    context "with custom top-level namespace config" do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build(top_namespace: "my_app")
      end

      it "returns text and optional meta" do
        template, meta = messages[:filled?, path: [:name]]

        expect(template.()).to eql("must be filled")
        expect(meta).to eql({})
      end
    end

    context "when called repeatedly" do
      it "returns the same template for the same predicate and options" do
        first, = messages[:filled?, path: [:name]]
        second, = messages[:filled?, path: [:name]]

        expect(second.key).to eql(first.key)
        expect(second.()).to eql("must be filled")
      end

      it "finds the message for each set of options" do
        expect(messages[:size?, path: [:name], arg_type: Integer, val_type: String].first.(size: 2))
          .to eql("length must be 2")
        expect(messages[:size?, path: [:name], arg_type: Range, val_type: String].first.(size_left: 1, size_right: 2))
          .to eql("length must be within 1 - 2")
        expect(messages[:size?, path: [:name], arg_type: Integer, val_type: String].first.(size: 3))
          .to eql("length must be 3")
      end

      it "returns nil each time no message is found" do
        2.times { expect(messages[:not_a_predicate?, path: [:name]]).to be_nil }
      end

      it "finds messages loaded after an earlier lookup" do
        expect(messages[:filled?, path: [:name]].first.()).to eql("must be filled")

        messages.config.load_paths << SPEC_ROOT.join("fixtures/locales/en.yml")
        messages.prepare

        expect(messages[:filled?, path: [:email]].first.()).not_to be_nil
        expect(messages[:filled?, path: [:name]].first.()).to eql("must be filled")
      end

      it "does not share lookups with a merged copy" do
        expect(messages[:filled?, path: [:name]].first.()).to eql("must be filled")

        merged = messages.merge(en: {dry_schema: {errors: {filled?: "needs a name"}}})

        expect(merged[:filled?, path: [:name]].first.()).to eql("needs a name")
        expect(messages[:filled?, path: [:name]].first.()).to eql("must be filled")
      end
    end

    context "with lookup paths using %{} tokens" do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build(lookup_paths: ["%{root}.%{predicate}"])
      end

      it "finds the message for each predicate" do
        expect(messages[:filled?, path: [:name]].first.()).to eql("must be filled")
        expect(messages[:key?, path: [:name]].first.()).to eql("is missing")
      end
    end

    context "with no load paths" do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build(load_paths: [])
      end

      it "does not cause data to be nil, leading to a NoMethodError" do
        result = messages[:filled?, path: [:name]]

        expect(result).to be_nil
      end
    end

    context "interpolation" do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build.merge(
          stringify_keys(
            en: {
              dry_schema: {
                errors: {
                  format?: {
                    text: "%{input} looks weird",
                    code: "bad"
                  }
                }
              }
            }
          )
        )
      end

      it "interpolates into text" do
        template, meta = messages[:format?, path: [:name]]

        expect(template.(input: "it really")).to eql("it really looks weird")
        expect(meta).to eql(code: "bad")
      end
    end
  end

  describe "#merge" do
    context "with :text and meta" do
      it "nests the message hash" do
        merged = messages.merge(
          stringify_keys(
            en: {
              dry_schema: {
                errors: {
                  format?: {
                    text: "%{input} looks weird",
                    code: 102
                  }
                }
              }
            }
          )
        )

        expect(merged.data["en.dry_schema.errors.format?"])
          .to eql(text: "%{input} looks weird", meta: {code: 102})
      end
    end
  end

  describe ".flat_hash" do
    subject(:output) { Dry::Schema::Messages::YAML.flat_hash(input) }

    let(:input) do
      stringify_keys(en: {dry_schema: {errors: messages}})
    end

    describe "simple text messages" do
      let(:messages) do
        {format?: "not ok",
         else?: "should be something else"}
      end

      it "returns string templates" do
        expect(output).to eql(
          "en.dry_schema.errors.else?" => {
            text: "should be something else",
            meta: {}
          },
          "en.dry_schema.errors.format?" => {
            text: "not ok",
            meta: {}
          }
        )
      end
    end

    describe "messages with meta" do
      let(:messages) do
        {
          gt?: {
            text: "must be greater",
            code: 856
          },
          size?: {
            arg: {
              default: "size must be good",
              range: {
                text: "size must fit within the range",
                code: 312
              }
            },
            value: {
              string: {
                arg: {
                  default: "length must be good",
                  range: {
                    text: "length must fit within the range",
                    code: 423
                  }
                }
              }
            }
          },
          rules: {
            format?: {
              text: "not ok",
              code: -101
            },
            text: {
              filled?: {
                text: "text not filled",
                code: 476
              }
            }
          }
        }
      end

      it "returns string templates" do
        expect(output).to eql(
          "en.dry_schema.errors.gt?" => {
            text: "must be greater", meta: {code: 856}
          },
          "en.dry_schema.errors.size?.arg.default" => {
            text: "size must be good", meta: {}
          },
          "en.dry_schema.errors.size?.arg.range" => {
            text: "size must fit within the range", meta: {code: 312}
          },
          "en.dry_schema.errors.size?.value.string.arg.default" => {
            text: "length must be good", meta: {}
          },
          "en.dry_schema.errors.size?.value.string.arg.range" => {
            text: "length must fit within the range", meta: {code: 423}
          },
          "en.dry_schema.errors.rules.format?" => {
            text: "not ok", meta: {code: -101}
          },
          "en.dry_schema.errors.rules.text.filled?" => {
            text: "text not filled", meta: {code: 476}
          }
        )
      end
    end
  end
end
