require 'dry/schema/key_map'

RSpec.describe Dry::Schema::KeyMap do
  subject(:key_map) { Dry::Schema::KeyMap.new(keys) }

  context 'with a flat list of keys' do
    let(:keys) { %i[id name email] }

    describe '#each' do
      it 'yields each key' do
        result = []

        key_map.each {|key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:id], Dry::Schema::Key[:name], Dry::Schema::Key[:email]]
        )
      end
    end

    describe '#stringified' do
      it 'returns a key map with stringified keys' do
        result = []
        hash = {'id' => 1, 'name' => 'Jane', 'email' => 'jade@doe.org'}

        key_map.stringified.each {|key| key.read(hash) {|value| result << value } }

        expect(result).to eql([1, 'Jane', 'jade@doe.org'])
      end
    end

    describe '#+' do
      let(:other) { Dry::Schema::KeyMap.new([:age, :address]) }
      let(:keys) { %i[id name] }

      it 'merges two key maps' do
        expect((key_map + other).map(&:id)).to eql(%i[id name age address])
      end
    end
  end

  context 'with a nested hash' do
    let(:keys) { [:id, :name, {contact: %i[email phone]}] }

    describe '#each' do
      it 'yields each key and nested key map' do
        result = []

        key_map.each {|key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:id],
           Dry::Schema::Key[:name],
           Dry::Schema::Key::Hash[:contact, members: Dry::Schema::KeyMap[:email, :phone]]]
        )
      end
    end

    describe '#stringified' do
      it 'returns a key map with stringified keys' do
        result = []

        hash = {
          'id'      => 1,
          'name'    => 'Jane',
          'contact' => {'email' => 'jade@doe.org', 'phone' => 123}
        }

        key_map.stringified.each {|key| key.read(hash) {|value| result << value } }

        expect(result).to eql([1, 'Jane', {'email' => 'jade@doe.org', 'phone' => 123}])
      end
    end
  end

  context 'with a nested array' do
    let(:keys) { [:title, [:tags, [:name]]] }

    describe '#each' do
      it 'yields each key and nested key map' do
        result = []

        key_map.each {|key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:title], Dry::Schema::Key::Array[:tags, member: Dry::Schema::KeyMap[:name]]]
        )
      end
    end

    describe '#stringified' do
      it 'returns a key map with stringified keys' do
        result = []

        hash = {
          'title' => 'Bohemian Rhapsody',
          'tags'  => [{'name' => 'queen'}, {'name' => 'classic'}]
        }

        key_map.stringified.each {|key| key.read(hash) {|value| result << value } }

        expect(result).to eql(['Bohemian Rhapsody', [{'name' => 'queen'}, {'name' => 'classic'}]])
      end
    end
  end
end
