# frozen_string_literal: true

RSpec.describe 'Macros #array' do
  context 'predicate without options' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).array(:filled?, :str?)
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w[a b c] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [[1, 2], '', 'foo'] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ['must be a string'], 1 => ['must be filled'])
      end
    end

    context 'with invalid input type' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end
  end

  context 'predicate with options' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).array(size?: 3)
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [[1, 2, 3], 'foo'] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [[1, 2], 'foo'] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ['size must be 3'])
      end
    end

    context 'with invalid input type' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end
  end

  context 'with filled macro' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).value(:array).filled(size?: 2) { each(:str?) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w[a b] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'when value is not valid' do
      let(:input) { { foo: ['foo'] } }

      it 'is not successful' do
        expect(result).to be_failing(['size must be 2'])
      end
    end

    context 'when value has invalid elements' do
      let(:input) { { foo: [:foo, 'foo'] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ['must be a string'])
      end
    end
  end

  context 'with maybe macro' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).maybe(:array).maybe(:array?) { each(:str?) }
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w[a b c] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [:foo, 'foo'] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ['must be a string'])
      end
    end
  end

  context 'with external schema macro' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).array(FooSchema)
      end
    end

    before do
      FooSchema = Dry::Schema.define do
        required(:bar).filled(:str?)
      end
    end

    after do
      Object.send(:remove_const, :FooSchema)
    end

    context 'with valid input' do
      let(:input) { { foo: [{ bar: 'baz' }] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'when value is not valid' do
      let(:input) { { foo: [{ bar: 1 }] } }

      it 'is not successful' do
        # FIXME: our be_failing didn't work with such nested wow hash
        expect(result.messages).to eql(foo: { 0 => { bar: ['must be a string'] } })
      end
    end
  end

  context 'with a block' do
    shared_context 'hash member' do
      it 'passes when all elements are valid' do
        songs = [
          { title: 'Hello', author: 'Jane' },
          { title: 'World', author: 'Joe' }
        ]

        expect(schema.(songs: songs)).to be_success
      end

      it 'fails when value is not an array' do
        expect(schema.(songs: 'oops').messages).to eql(songs: ['must be an array'])
      end

      it 'fails when not all elements are valid' do
        songs = [
          { title: 'Hello', author: 'Jane' },
          { title: nil, author: 'Joe' },
          { title: 'World', author: nil },
          { title: nil, author: nil }
        ]

        expect(schema.(songs: songs).messages).to eql(
          songs: {
            1 => { title: ['must be filled'] },
            2 => { author: ['must be filled'] },
            3 => { title: ['must be filled'], author: ['must be filled'] }
          }
        )
      end
    end

    context 'with a nested schema' do
      subject(:schema) do
        Dry::Schema.define do
          required(:songs).array(:hash?) do
            schema do
              required(:title).filled
              required(:author).filled
            end
          end
        end
      end

      include_context 'hash member'
    end

    context 'with a nested hash' do
      subject(:schema) do
        Dry::Schema.define do
          required(:songs).array(:hash) do
            required(:title).filled
            required(:author).filled
          end
        end
      end

      include_context 'hash member'
    end
  end

  context 'with inferred predicates and a form schema' do
    context 'predicate w/o options' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:songs).value(:array?).each(:str?)
        end
      end

      it 'passes when all elements are valid' do
        songs = %w[hello world]

        expect(schema.(songs: songs)).to be_success
      end

      it 'fails when value is not an array' do
        expect(schema.(songs: 'oops').messages).to eql(songs: ['must be an array'])
      end

      it 'fails when not all elements are valid' do
        songs = ['hello', nil, 2]

        expect(schema.(songs: songs).messages).to eql(
          songs: {
            1 => ['must be a string'],
            2 => ['must be a string']
          }
        )
      end
    end
  end

  context 'using other schema for elements' do
    let(:schema) do
      Dry::Schema.Params do
        optional(:foo).array(Test::ElementSchema)
      end
    end

    before do
      Test::ElementSchema = Dry::Schema.Params do
        required(:bar).value(:integer)
      end
    end

    it 'applies other schema to element values' do
      expect(schema.(foo: [{ bar: '123' }])).to be_success
    end
  end

  context 'primitive array type with nested schema' do
    it 'is not allowed for chained macros' do
      nominal_array = Dry::Types::Nominal.new(Array)
      expect {
        Dry::Schema.Params do
          required(:values).value(nominal_array).each { hash {  } }
        end
      }.to raise_error(ArgumentError, /Types::Constructor/)
    end

    it 'is not allowed for schemas in parameters' do
      nominal_array = Dry::Types::Nominal.new(Array)
      schema = Dry::Schema.Params { required(:bar).value(:integer) }

      expect {
        Dry::Schema.Params do
          required(:values).value(nominal_array, schema)
        end
      }.to raise_error(ArgumentError, /Types::Constructor/)
    end
  end
end
