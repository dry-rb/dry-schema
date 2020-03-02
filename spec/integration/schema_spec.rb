# frozen_string_literal: true

require 'dry/schema'

RSpec.describe Dry::Schema, '.define' do
  shared_context 'valid schema' do
    it 'passes when input is valid' do
      expect(schema.(email: 'jane@doe')).to be_success
      expect(schema.(email: 'jane@doe', age: 21)).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(email: nil)).to be_failure
      expect(schema.(email: nil, age: 21)).to be_failure
      expect(schema.(email: nil, age: '21')).to be_failure
    end

    it 'produces error messages' do
      result = schema.(email: '')

      expect(result.errors[:email]).to include('must be filled')
    end

    it 'returns a frozen result' do
      expect(schema.(email: '')).to be_frozen
    end
  end

  context 'using macros' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).filled(:str?)
        optional(:age).value(:int?)
      end
    end

    include_context 'valid schema'
  end

  context 'using a block' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email) { filled? & str? }
        optional(:age) { int? }
      end
    end

    include_context 'valid schema'
  end

  context 'chaining calls' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).value(:str?).filled
        optional(:age).value(:int?)
      end
    end

    include_context 'valid schema'
  end

  context 'each macro' do
    context 'with simple predicates' do
      subject(:schema) do
        Dry::Schema.define do
          required(:tags).value(:array).each(:str?) { size?(2..4) }
        end
      end

      it 'passes when input is valid' do
        expect(schema.(tags: %w[red blue])).to be_success
      end

      it 'fails when input is not valid' do
        expect(schema.(tags: ['red', nil])).to be_failure
        expect(schema.(tags: %w[red black])).to be_failure
      end
    end

    context 'with a nested schema' do
      subject(:schema) do
        Dry::Schema.define do
          required(:tags).value(:array).each do
            schema do
              required(:name).filled(:string)
            end
          end
        end
      end

      it 'passes when input is valid' do
        expect(schema.(tags: [{ name: 'red' }, { name: 'blue' }])).to be_success
      end

      it 'fails when input is not valid' do
        expect(schema.(tags: [{ name: 'red' }, { title: 'blue' }])).to be_failure
      end
    end
  end

  context 'schema with callbacks' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:name).maybe(:str?)
        required(:date).maybe(:date?)

        before(:key_coercer) do |result|
          { name: 'default' }.merge(result.to_h)
        end

        after(:rule_applier) do |result|
          result.to_h.compact
        end
      end
    end

    it 'calls callbacks' do
      expect(schema.(date: nil).to_h).to eq(name: 'default')
    end
  end

  context 'nested schema' do
    subject(:schema) do
      Dry::Schema.define do
        required(:user).hash do
          required(:name).filled
          required(:age).filled(:int?)
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(user: { name: 'Jane', age: 35 })).to be_success
    end

    it 'fails when input is not valid' do
      result = schema.(user: { age: 35 })

      expect(result).to be_failure
      expect(result.errors[:user]).to eql(name: ['is missing'])

      result = schema.(user: { name: 'Jane', age: '35' })

      expect(result).to be_failure
      expect(result.errors[:user]).to eql(age: ['must be an integer'])
    end
  end

  context 'with coercible type specs' do
    subject(:schema) do
      Dry::Schema.define do
        required(:birthday).value(Types::Params::Date).value(:date?)
        optional(:age).value(Types::Params::Integer).value(:int?)
      end
    end

    it 'passes when input is valid' do
      expect(schema.(birthday: '1990-01-02')).to be_success
      expect(schema.(birthday: '1990-01-02', age: '21')).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(birthday: 'dooh', age: '21')).to be_failure
      expect(schema.(birthday: 'dooh', age: nil)).to be_failure
      expect(schema.(birthday: '1990-01-02', age: 'oops')).to be_failure
    end

    it 'produces error messages' do
      result = schema.(birthday: '1990-01-02', age: 'oops')

      expect(result.errors[:age]).to include('must be an integer')
    end
  end

  context 'with constrained type specs' do
    context 'curried rules' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value(Types::Params::Integer.constrained(gteq: 18))
        end
      end

      it 'produces error messages' do
        expect(schema.(age: 'oops').errors[:age]).to include('must be an integer')
        expect(schema.(age: '17').errors[:age]).to include('must be greater than or equal to 18')
      end
    end

    context '1-arity rules' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value(Types::Params::Integer.constrained([:odd]))
        end
      end

      it 'produces error messages' do
        expect(schema.(age: 'oops').errors[:age]).to include('must be an integer')
        expect(schema.(age: '18').errors[:age]).to include('must be odd')
      end
    end

    context 'sum type' do
      let(:type) do
        Types::Params::Integer.constrained(gteq: 18) | Types::String.constrained(eql: 'old enough')
      end

      subject(:schema) do
        type = self.type
        Dry::Schema.define { required(:age).value(type) }
      end

      it 'accepts valid input' do
        expect(schema.(age: '19')).to be_success
        expect(schema.(age: 'old enough')).to be_success
      end

      it 'produces error messages' do
        expect(schema.(age: 'young').errors[:age])
          .to include('must be an integer or must be equal to old enough')

        expect(schema.(age: '17').errors[:age])
          .to include('must be an integer or must be equal to old enough')
      end
    end

    context 'constrained sum type' do
      let(:type) do
        int = Types::Integer
        (int.constrained([:odd]) | int.constrained(eql: 0)).constrained(gteq: 18)
      end

      subject(:schema) do
        type = self.type
        Dry::Schema.define { required(:age).value(type) }
      end

      it 'accepts valid input' do
        expect(schema.(age: 19)).to be_success
      end

      it 'produces error messages' do
        expect(schema.(age: 17).errors[:age])
          .to include('must be greater than or equal to 18')

        expect(schema.(age: 16).errors[:age])
          .to include('must be odd or must be equal to 0')
      end
    end
  end
end
