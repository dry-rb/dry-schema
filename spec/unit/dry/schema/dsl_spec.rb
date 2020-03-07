# frozen_string_literal: true

require 'dry/schema/dsl'
require 'dry/schema/compiler'

RSpec.describe Dry::Schema::DSL do
  subject(:dsl) do
    Dry::Schema::DSL.new
  end

  describe '#required' do
    it 'raises ArgumentError if a non-symbol name was provided' do
      expect { dsl.required('foo') }.to raise_error(ArgumentError, 'Key +foo+ is not a symbol')
    end
  end

  describe '#optional' do
    it 'raises ArgumentError if a non-symbol name was provided' do
      expect { dsl.optional('foo') }.to raise_error(ArgumentError, 'Key +foo+ is not a symbol')
    end
  end

  describe '#schema' do
    it 'defines a rule from a nested schema' do
      dsl.required(:user).hash do
        required(:name).filled
      end

      rules = dsl.call.rules

      expect(rules[:user].(user: { name: 'Jane' })).to be_success

      expect(rules[:user].(user: {})).to be_failure
      expect(rules[:user].(user: { name: '' })).to be_failure
    end
  end

  describe '#config' do
    let(:namespace) { :test_namespace }
    let(:replacement_namespace) { :replacement_test_namespace }

    it "uses a dup of the parent's config when a parent is present" do
      config = Dry::Schema::Config.new.tap { |c| c.messages.namespace = namespace }
      parent = Dry::Schema::DSL.new(config: config)
      dsl = Dry::Schema::DSL.new(parent: parent)

      expect(dsl.config.messages.namespace).to eq(namespace)

      parent.config.messages.namespace = replacement_namespace
      expect(dsl.config.messages.namespace).not_to eq(replacement_namespace)
    end

    it 'uses a dup of the global config when no parent is present' do
      Dry::Schema.config.messages.namespace = namespace
      expect(dsl.config.messages.namespace).to eq(namespace)

      Dry::Schema.config.messages.namespace = replacement_namespace
      expect(dsl.config.messages.namespace).not_to eq(replacement_namespace)
    end

    it 'raises an ArgumentError if the parent configs differ' do
      parent = [namespace, namespace, replacement_namespace, namespace].map do |namespace|
        config = Dry::Schema::Config.new.tap { |c| c.messages.namespace = namespace }
        Dry::Schema::DSL.new(config: config)
      end

      expect { Dry::Schema::DSL.new(parent: parent) }
        .to raise_error(ArgumentError, /Parent configs differ/)
    end

    it 'does not raise an error if the parent configs are the same' do
      parent = Array.new(4) do
        config = Dry::Schema::Config.new.tap { |c| c.messages.namespace = namespace }
        Dry::Schema::DSL.new(config: config)
      end

      expect { Dry::Schema::DSL.new(parent: parent) }.not_to raise_error
    end
  end
end
