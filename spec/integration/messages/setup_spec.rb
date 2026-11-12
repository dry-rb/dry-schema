# frozen_string_literal: true

require "dry/schema/messages/i18n"

RSpec.describe Dry::Schema::Messages, ".setup" do
  it "sets up a messages namespaced backend with provided config" do
    config = Dry::Schema::Config.new
    config.messages.backend = :i18n
    config.messages.top_namespace = "contracts"
    config.messages.default_locale = "pl"

    backend = Dry::Schema::Messages.setup(config.messages)

    expect(backend).to be_instance_of(Dry::Schema::Messages::I18n)
    expect(backend.config.default_locale).to eql("pl")
  end

  context "with a custom backend class" do
    let(:backend_class) {
      Class.new(Dry::Schema::Messages::YAML) do
        def custom? = true
      end
    }

    let(:config) { Dry::Schema::Config.new.tap { _1.messages.backend = backend_class } }

    it "builds messages from that class with the provided config" do
      config.messages.default_locale = :pl

      backend = Dry::Schema::Messages.setup(config.messages)

      expect(backend).to be_instance_of(backend_class)
      expect(backend).to be_custom
      expect(backend.config.default_locale).to be(:pl)
    end

    it "applies the namespace" do
      config.messages.namespace = :user

      backend = Dry::Schema::Messages.setup(config.messages)

      expect(backend).to be_instance_of(Dry::Schema::Messages::Namespaced)
    end

    it "is used for a schema's error messages" do
      backend_class.class_eval do
        def get(key, options = EMPTY_HASH)
          result = super
          result&.merge(text: result[:text].upcase)
        end
      end

      # The DSL block is instance_eval'd, so capture the class in a local first
      messages_backend = backend_class

      schema = Dry::Schema.define do
        config.messages.backend = messages_backend

        required(:name).filled(:string)
      end

      expect(schema.(name: "").errors.to_h).to eql(name: ["MUST BE FILLED"])
    end
  end

  context "with a custom backend object" do
    it "builds messages by calling #build with the backend options" do
      config = Dry::Schema::Config.new
      built = Dry::Schema::Messages::YAML.build
      builder = double(:builder, build: built)
      config.messages.backend = builder

      expect(Dry::Schema::Messages.setup(config.messages)).to be(built)
      expect(builder).to have_received(:build).with(hash_including(:load_paths, :top_namespace))
      expect(builder).to have_received(:build).with(hash_excluding(:backend))
      expect(builder).to have_received(:build).with(hash_excluding(:namespace))
    end
  end

  it "raises for an unknown backend identifier" do
    config = Dry::Schema::Config.new
    config.messages.backend = :unknown

    expect { Dry::Schema::Messages.setup(config.messages) }
      .to raise_error(RuntimeError, "+unknown+ is not a valid messages identifier")
  end
end
