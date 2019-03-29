# frozen_string_literal: true

RSpec.describe Dry::Schema::MessageCompiler, '#visit' do
  include_context :message_compiler

  let(:visitor) { :visit }

  context 'with a :failure node' do
    let(:node) do
      [:failure, [:age, [:key, [:age, [:predicate, [:int?, [[:input, '17']]]]]]]]
    end

    it 'returns a message for :int? failure with :rule inferred from :failure identifier' do
      expect(result.path).to eql([:age])
      expect(result).to eql('must be an integer')
    end
  end

  context 'with an unsupported predicate' do
    let(:node) do
      [:key, [%i[user address street], [:predicate, [:oops?, [[:input, '17']]]]]]
    end

    it 'raises MissingMessageError' do
      expect { result }.to raise_error(Dry::Schema::MissingMessageError, <<~STR)
        Message template for :street under "user.address" was not found
      STR
    end
  end
end
