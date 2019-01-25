RSpec.describe 'Macros #maybe' do
  describe 'with no args' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).maybe
      end
    end

    it 'generates none? | filled? rule' do
      expect { schema }.to raise_error(ArgumentError)
    end
  end

  describe 'with a type spec' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).maybe(:string, format?: /@/)
      end
    end

    it 'generates none? | str? rule' do
      expect(schema.(email: nil)).to be_success
      expect(schema.(email: 'jane@doe.org')).to be_success
      expect(schema.(email: 'jane').errors).to eql(email: ['is in invalid format'])
    end
  end

  describe 'with a predicate with args' do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe(min_size?: 3)
      end
    end

    it 'generates none? | (filled? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end

  describe 'with a block' do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe { str? & min_size?(3) }
      end
    end

    it 'generates none? | (str? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end

  describe 'with an optional key and a block with schema' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:employee, [:nil, :hash]).maybe(:hash?) do
          schema do
            required(:id, :string).filled(:str?)
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(employee: { id: '1' })).to be_success
    end

    it 'passes when key is missing' do
      expect(schema.({})).to be_success
    end

    it 'passes when value is nil' do
      expect(schema.(employee: nil)).to be_success
    end

    it 'fails when value for nested schema is invalid' do
      expect(schema.(employee: { id: 1 }).messages).to eql(
        employee: { id: ['must be a string'] }
      )
    end
  end

  describe 'with a predicate and a block' do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).maybe(:str?) { min_size?(3) }
      end
    end

    it 'generates none? | (str? & min_size?) rule' do
      expect(schema.(name: nil).messages).to be_empty

      expect(schema.(name: 'jane').messages).to be_empty

      expect(schema.(name: 'xy').messages).to eql(
        name: ['size cannot be less than 3']
      )
    end
  end
end

