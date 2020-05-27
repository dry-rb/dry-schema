# frozen_string_literal: true

require "dry/schema/messages/i18n"

RSpec.describe Dry::Schema, "with localized messages" do
  describe "defining schema" do
    context "without a namespace" do
      subject(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n
          config.messages.load_paths = %w[en pl ja]
            .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

          required(:email).value(:filled?)
        end
      end

      describe "#messages" do
        it "returns localized error messages" do
          expect(schema.(email: "").messages(locale: :pl)).to eql(
            email: ["Proszę podać adres email"]
          )
        end

        it "returns localized error message with defined whitespace character when full option is set to true" do
            expect(schema.(email: "").messages(locale: :ja, full: true)).to eql(email: ["Eメールは必須入力です"])
        end
      end
    end

    context "with a namespace" do
      subject(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n
          config.messages.namespace = :user
          config.messages.load_paths = %w[en pl ja]
            .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

          required(:email).value(:filled?)
        end
      end

      describe "#errors" do
        it "returns localized error messages" do
          expect(schema.(email: "").errors).to eql(email: ["Please provide your email"])

          expect(schema.(email: "").errors(locale: :pl)).to eql(email: ["Hej user! Dawaj ten email no!"])
        end
      end
    end

    context "with a config.default_locale set" do
      subject(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n
          config.messages.namespace = :user
          config.messages.default_locale = :pl
          config.messages.load_paths = %w[en pl ja]
            .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

          required(:email).value(:filled?)
        end
      end

      describe "#errors" do
        it "returns localized error messages" do
          expect(schema.(email: "").errors(locale: :en)).to eql(email: ["Please provide your email"])

          expect(schema.(email: "").errors).to eql(email: ["Hej user! Dawaj ten email no!"])
        end

        it "returns localized error messages with defined whitespace character for 'full' option" do
          schema = Dry::Schema.define do
            config.messages.backend = :i18n
            config.messages.namespace = :user
            config.messages.default_locale = :ja
            config.messages.load_paths = %w[en pl ja]
                                             .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

            required(:email).value(:filled?)
          end

          expect(schema.(email: "").messages(full: true)).to eql(email: ["Eメールは必須入力です"])
        end
      end
    end
  end
end
