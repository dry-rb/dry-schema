# frozen_string_literal: true

require 'dry/schema/processor'

RSpec.describe Dry::Schema::Processor, '#merge' do
  context 'without parents' do
    subject(:schema) { left.merge(right) }

    let(:left) do
      Dry::Schema.define do
        after(:rule_applier) do |result|
          result.output[:left] = true
        end

        required(:name).filled(:string)
      end
    end

    let(:right) do
      Dry::Schema.define do
        after(:rule_applier) do |result|
          result.output[:right] = true
        end

        required(:age).value(Types::Params::Integer)
      end
    end

    it 'maintains rules' do
      expect(schema.(name: '', age: 'foo').errors.to_h).to eql(
        name: ['must be filled'], age: ['must be an integer']
      )
    end

    it 'maintains types' do
      expect(schema.(name: '', age: '36').errors.to_h).to eql(
        name: ['must be filled']
      )
    end

    it 'maintains hooks' do
      expect(schema.(name: 'Jane', age: 36).to_h).to eql(
        name: 'Jane', age: 36, left: true, right: true
      )
    end
  end

  context 'with parents' do
    subject(:schema) { left.merge(right) }

    let(:left_parent) do
      Dry::Schema.define do
        required(:email).filled(:string)
      end
    end

    let(:left) do
      Dry::Schema.define(parent: left_parent) do
        required(:name).filled(:string)
      end
    end

    let(:right_parent) do
      Dry::Schema.define do
        required(:address).filled(:string)
      end
    end

    let(:right) do
      Dry::Schema.define(parent: right_parent) do
        required(:age).value(:integer)
      end
    end

    it 'maintains all rules' do
      expect(schema.(name: '', age: 'foo').errors.to_h).to eql(
        name: ['must be filled'],
        age: ['must be an integer'],
        email: ['is missing'],
        address: ['is missing']
      )
    end
  end
end
