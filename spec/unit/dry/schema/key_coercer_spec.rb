require 'dry/schema/key_map'
require 'dry/schema/key_coercer'

RSpec.describe Dry::Schema::KeyCoercer do
  subject(:key_coercer) { Dry::Schema::KeyCoercer.new(key_map, &coercer) }

  let(:coercer) { :to_s.to_proc }


  context 'with a flat key map' do
    let(:key_map) { Dry::Schema::KeyMap[:a, :b] }

    describe '#call' do
      it 'returns a new hash with coerced keys' do
        expect(key_coercer.call(a: 1, b: 2)).to eql('a' => 1, 'b' => 2)
      end
    end
  end

  context 'with a nested hash key map' do
    let(:key_map) { Dry::Schema::KeyMap[:a, b: [:c]] }

    describe '#call' do
      it 'returns a new hash with coerced keys' do
        expect(key_coercer.call(a: 1, b: { c: 2 })).to eql('a' => 1, 'b' => { 'c' => 2 })
      end
    end
  end

  context 'with a nested array key map' do
    let(:key_map) { Dry::Schema::KeyMap[:a, [:b, [:c]]] }

    describe '#call' do
      it 'returns a new hash with coerced keys' do
        expect(key_coercer.call(a: 1, b: [{ c: 2 }, { c: 3 }])).to eql(
          'a' => 1, 'b' => [{ 'c' => 2 }, { 'c' => 3 }]
        )
      end
    end
  end
end