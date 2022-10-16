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
end
