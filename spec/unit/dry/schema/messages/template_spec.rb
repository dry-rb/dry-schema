# frozen_string_literal: true

require 'dry/schema/messages/template'
require 'dry/schema/messages/abstract'

RSpec.describe Dry::Schema::Messages::Template do
  let(:messages) { instance_double('Dry::Schema::Messages::Abstract') }
  let(:key) { 'key' }
  let(:options) { { name: 'Alice', locale: :en } }

  subject(:template) do
    Dry::Schema::Messages::Template.new(
      messages: messages,
      key: key,
      options: options
    )
  end

  describe '#data' do
    it 'delegates to the message backend' do
      input = { adjective: 'rad', ignored: 'param' }
      data = { adjective: 'rad', name: 'Alice' }

      allow(messages).to receive(:key?)
        .with(key, options)
        .and_return(true)

      allow(messages).to receive(:interpolatable_data)
        .with(key, options, **options, **input)
        .and_return(data)

      expect(template.data(input)).to eq(data)
    end

    it 'raises a KeyError when the key does not exist' do
      allow(messages).to receive(:key?)
        .with(key, options)
        .and_return(false)

      expect { template.data }.to raise_error(KeyError)
    end
  end

  describe '#call' do
    it 'delegates to the message backend' do
      data = { adjective: 'rad', name: 'Alice' }
      message = 'Alice is awesome and rad'

      allow(messages).to receive(:key?)
        .with(key, options)
        .and_return(true)

      allow(messages).to receive(:interpolate)
        .with(key, options, **data)
        .and_return(message)

      expect(template.(data)).to eq(message)
    end

    it 'raises a KeyError when the key does not exist' do
      allow(messages).to receive(:key?)
        .with(key, options)
        .and_return(false)

      expect { template.() }.to raise_error(KeyError)
    end
  end
end
