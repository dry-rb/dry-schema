# frozen_string_literal: true

RSpec.describe Dry::Schema::MessageCompiler, '#call' do
  subject(:message_compiler) do
    Dry::Schema::MessageCompiler.new(Dry::Schema::Messages::YAML.build)
  end

  it 'returns an empty hash when there are no errors' do
    expect(message_compiler.([])).to be_empty
  end
end
