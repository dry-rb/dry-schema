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
        required(:nums).value(array[:integer])
      end
    end

    it 'uses form coercion' do
      expect(schema.(nums: %w(1 2 3)).to_h).to eql(nums: [1, 2, 3])
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
end
