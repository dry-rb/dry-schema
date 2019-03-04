# frozen_string_literal: true

RSpec.shared_context :message_compiler do
  subject(:compiler) { Dry::Schema::MessageCompiler.new(messages) }

  let(:messages) do
    Dry::Schema::Messages::YAML.build
  end

  let(:result) do
    compiler.public_send(visitor, node, Dry::Schema::MessageCompiler::EMPTY_OPTS.dup)
  end
end
