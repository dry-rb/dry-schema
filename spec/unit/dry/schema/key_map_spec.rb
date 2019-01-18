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
  end

  context 'with a nested hash' do
    let(:keys) { [:id, :name, { contact: [:email, :phone] }] }

    describe '#each' do
      it 'yields each key and nested key map' do
        result = []

        key_map.each {|key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:id],
           Dry::Schema::Key[:name],
           { Dry::Schema::Key[:contact] => Dry::Schema::KeyMap[:email, :phone] }]
        )
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
          [Dry::Schema::Key[:title], Dry::Schema::Key[:tags] => [Dry::Schema::KeyMap[:name]]]
        )
      end
    end
  end
end
