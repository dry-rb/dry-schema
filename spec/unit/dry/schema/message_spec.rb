# frozen_string_literal: true

require 'dry/schema/message'

RSpec.describe Dry::Schema::Message do
  def msg(path)
    Dry::Schema::Message.new(text: 'failed', predicate: :int?, path: path, input: nil)
  end

  describe '#<=>' do
    it 'returns -1 when path is lower in hierarchy' do
      expect(msg(%i[user]) <=> msg(%i[user age])).to be(-1)
    end

    it 'returns 0 when path is the same' do
      expect(msg(%i[user age]) <=> msg(%i[user age])).to be(0)
    end

    it 'returns 1 when path is higher in hierarchy' do
      expect(msg(%i[user age]) <=> msg(%i[user])).to be(1)
    end

    it 'raises when paths have a different root' do
      expect { msg(%i[user]) <=> msg(%i[address]) }
        .to raise_error(ArgumentError, 'Cannot compare messages from different root paths')
    end
  end
end
