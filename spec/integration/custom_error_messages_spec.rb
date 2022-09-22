# frozen_string_literal: true

require "dry/schema/messages/i18n"

RSpec.describe Dry::Schema do
  shared_context "schema with customized messages" do
    describe "#messages" do
      it "returns compiled error messages" do
        expect(schema.(email: "").messages).to eql(
          email: ["Please provide your email"]
        )
      end
    end
  end

  context "yaml" do
    subject(:schema) do
      Dry::Schema.define do
        configure do |config|
          config.messages.load_paths << SPEC_ROOT.join("fixtures/locales/en.yml")
        end

        required(:email).value(:filled?)
      end
    end

    include_context "schema with customized messages"
  end

  context "i18n" do
    before do
      I18n.load_path << SPEC_ROOT.join("fixtures/locales/en.yml")
      I18n.backend.load_translations
    end

    context "with custom messages set globally" do
      subject(:schema) do
        Dry::Schema.define do
          configure do |config|
            config.messages.backend = :i18n
          end

          required(:email).value(:filled?)
        end
      end

      include_context "schema with customized messages"
    end

    context "with global configuration" do
      before do
        Dry::Schema.configure { |c| c.messages.backend = :i18n }
      end

      subject(:schema) do
        Dry::Schema.define do
          required(:email).value(:filled?)
        end
      end

      include_context "schema with customized messages"
    end
  end
end
