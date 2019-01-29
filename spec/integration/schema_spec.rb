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
        expect(schema.(tags: ['red', 'blue'])).to be_success
      end

      it 'fails when input is not valid' do
        expect(schema.(tags: ['red', nil])).to be_failure
        expect(schema.(tags: ['red', 'black'])).to be_failure
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

  context 'nested schema' do
    subject(:schema) do
      Dry::Schema.define do
        required(:user).schema do
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
end
