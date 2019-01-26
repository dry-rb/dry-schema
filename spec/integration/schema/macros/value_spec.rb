RSpec.describe 'Macros #value' do
  describe 'with no args' do
    it 'raises an exception' do
      expect { Dry::Schema.define { required(:email).value } }.to raise_error(
        ArgumentError, "wrong number of arguments (given 0, expected at least 1)"
      )
    end
  end

  describe 'with a type check predicate' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).value(:int?)
      end
    end

    it 'applies provided int? rule' do
      expect(schema.(age: nil).messages).to eql(
        age: ['must be an integer']
      )
    end
  end

  describe 'with a type spec and no predicate' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).value(:integer)
      end
    end

    it 'infers int? rule and applies it' do
      expect(schema.(age: nil).messages).to eql(
        age: ['must be an integer']
      )
    end
  end

  describe 'with a type spec and other predicates' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).value(:integer, :even?, gt?: 18)
      end
    end

    it 'infers int? rule and applies it before other rules' do
      expect(schema.(age: nil).errors).to eql( age: ['must be an integer'])
      expect(schema.(age: 19).errors).to eql( age: ['must be even'])
      expect(schema.(age: 18).errors).to eql( age: ['must be greater than 18'])
    end
  end

  describe 'with an invalid type spec' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).value(:custom, :even?, gt?: 18)
      end
    end

    before do
      Dry::Types.register('custom', Dry::Types::Definition.new(Dry::Schema::Macros::Value))
    end

    after do
      Dry::Types.container._container.delete('custom')
    end

    it 'raises an ArgumentError' do
      expect { schema }.to raise_error(ArgumentError, <<-STR.strip)
        Cannot infer type-check predicate from +:custom+ type spec
      STR
    end
  end

  describe 'with a predicate with args' do
    context 'with a flat arg' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value(:int?, gt?: 18)
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'must be greater than 18']
        )
      end
    end

    context 'with a second predicate with args' do
      subject(:schema) do
        Dry::Schema.define do
          required(:name).value(:str?, min_size?: 3, max_size?: 6)
        end
      end

      it 'generates str? & min_size? & max_size?' do
        expect(schema.(name: 'fo').messages).to eql(
          name: ['size cannot be less than 3', 'size cannot be greater than 6']
        )
      end
    end

    context 'with a range arg' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value(:int?, size?: 18..24)
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a block' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value { int? & size?(18..24) }
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a predicate and a block' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).value(:int?) { size?(18..24) }
        end
      end

      it 'generates int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be an integer', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a schema' do
      subject(:schema) do
        Dry::Schema.define do
          required(:data).value(DataSchema)
        end
      end

      before do
        DataSchema = Dry::Schema.define do
          required(:foo).filled(size?: 2..10)
        end
      end

      after do
        Object.send(:remove_const, :DataSchema)
      end

      it 'uses the schema' do
        expect(schema.(data: { foo: '' }).messages).to eql(
          data: { foo: ['must be filled', 'length must be within 2 - 10'] }
        )
      end
    end
  end
end
