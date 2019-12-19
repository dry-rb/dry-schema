# frozen_string_literal: true

RSpec.describe Dry::Schema, 'types specs' do
  context 'single type spec without rules' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:age).type(:integer)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end

  context 'single type spec with rules' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:age).type(:integer).value(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'single type spec with an array' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:nums).value(:array)
      end
    end

    it 'infers array? check' do
      expect(schema.(nums: nil).errors.to_h).to eql(nums: ['must be an array'])
    end
  end

  context 'single type spec with an array with a member' do
    shared_examples 'array with member' do
      it 'uses params coercion' do
        expect(schema.(nums: %w(1 2 3)).to_h).to eql(nums: [1, 2, 3])
      end

      it 'infers array? + each(:integer?)' do
        expect(schema.(nums: %w(1 oops 3)).errors.to_h).to eql(nums: { 1 => ['must be an integer'] })
      end
    end

    context 'with `value`' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:nums).value(array[:integer])
        end
      end

      include_examples 'array with member'
    end

    context 'with `maybe`' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:nums).maybe(array[:integer])
        end
      end

      include_examples 'array with member'
    end
  end

  context 'sum type spec without rules' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:age).type([:nil, :integer])
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
      expect(schema.('age' => '').to_h).to eql(age: nil)
    end
  end

  context 'sum type spec with rules' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:age).type([:nil, :integer]).maybe(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: nil).messages).to be_empty
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'using :any type' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:stuff).value(:any)
      end
    end

    it 'uses Any type that accepts all objects' do
      expect(schema.(stuff: 1)).to be_success
      expect(schema.(stuff: 'foo')).to be_success
      expect(schema.(stuff: Object.new)).to be_success
    end
  end

  context 'using a type object' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:age).value(Types::Params::Nil | Types::Params::Integer)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '').to_h).to eql(age: nil)
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end

  context 'nested schema' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:user).type(:hash).hash do
          required(:email).type(:string)
          required(:age).type(:integer)

          required(:address).type(:hash).hash do
            required(:street).type(:string)
            required(:city).type(:string)
            required(:zipcode).type(:string)

            required(:location).type(:hash).hash do
              required(:lat).type(:float)
              required(:lng).type(:float)
            end
          end
        end
      end
    end

    it 'uses form coercion for nested input' do
      input = {
        'user' => {
          'email' => 'jane@doe.org',
          'age' => '21',
          'address' => {
            'street' => 'Street 1',
            'city' => 'NYC',
            'zipcode' => '1234',
            'location' => { 'lat' => '1.23', 'lng' => '4.56' }
          }
        }
      }

      expect(schema.(input).to_h).to eql(
        user:  {
          email: 'jane@doe.org',
          age: 21,
          address: {
            street: 'Street 1',
            city: 'NYC',
            zipcode:  '1234',
            location: { lat: 1.23, lng: 4.56 }
          }
        }
      )
    end
  end

  context 'nested schema with arrays' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:song).type(:hash).value(:hash?).hash do
          required(:title).type(:string)

          required(:tags).type(:array).value(:array?).each do
            schema do
              required(:name).type(:string).value(:str?)
            end
          end
        end
      end
    end

    it 'fails to coerce gracefuly' do
      result = schema.(song: nil)

      expect(result.messages).to eql(song: ['must be a hash'])
      expect(result.to_h).to eql(song: nil)

      result = schema.(song: { tags: nil })

      expect(result.messages).to eql(song: { title: ['is missing'], tags: ['must be an array'] })
      expect(result.to_h).to eql(song: { tags: nil })
    end

    it 'uses form coercion for nested input' do
      input = {
        'song' => {
          'title' => 'dry-rb is awesome lala',
          'tags' => [{ 'name' => 'red' }, { 'name' => 'blue' }]
        }
      }

      expect(schema.(input).to_h).to eql(
        song: {
          title: 'dry-rb is awesome lala',
          tags: [{ name: 'red' }, { name: 'blue' }]
        }
      )
    end
  end

  context 'constructor on optional type' do
    let(:trimmed_string) do
      Types::String.optional.constructor do |str, &block|
        if str.is_a?(::String)
          stripped = str.strip

          if stripped.empty?
            nil
          else
            stripped
          end
        else
          block.(str)
        end
      end
    end

    shared_examples_for 'constructor type' do
      it 'applies constructor to input' do
        expect(schema.(name: ' John ').to_h).to eql(name: 'John')
        expect(schema.(name: ' ').to_h).to eql(name: nil)
        expect(schema.(name: nil).to_h).to eql(name: nil)
      end
    end

    context 'with type passed as object' do
      include_examples 'constructor type' do
        subject(:schema) do
          trimmed_string = self.trimmed_string

          Dry::Schema.define do
            required(:name).maybe(trimmed_string)
          end
        end
      end
    end

    context 'with type referenced by key' do
      include_examples 'constructor type' do
        subject(:schema) do
          trimmed_string = self.trimmed_string

          types = Dry::Schema::TypeContainer.new
          types.register('trimmed_string', trimmed_string)

          Dry::Schema.define do
            config.types = types

            required(:name).maybe(:trimmed_string)
          end
        end
      end
    end
  end
end
