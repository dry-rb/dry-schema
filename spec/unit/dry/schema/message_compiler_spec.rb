# frozen_string_literal: true

RSpec.describe Dry::Schema::MessageCompiler, '#call' do
  subject(:message_compiler) { Dry::Schema::MessageCompiler.new( Dry::Schema::Messages.default ) }

  it 'returns an empty hash when there are no errors' do
    expect(message_compiler.([])).to be_empty
  end
end
