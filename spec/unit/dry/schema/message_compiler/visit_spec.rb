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

  context 'with a predicate with text and extra meta-data' do
    let(:node) do
      [:failure, [:msisdn, [:key, [:msisdn, [:predicate, [:format?, [[:input, '31-213']]]]]]]]
    end

    let(:messages) do
      Dry::Schema::Messages::YAML.build.merge(
        stringify_keys(
          en: {
            dry_schema: {
              errors: {
                format?: {
                  code: 102,
                  text: '%{input} looks weird'
                }
              }
            }
          }
        )
      )
    end

    it 'returns a message for the predicate a long with the additional meta-data' do
      expect(result.path).to eql([:msisdn])
      expect(result.text).to eql('31-213 looks weird')
      expect(result.meta).to eql(code: 102)
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
