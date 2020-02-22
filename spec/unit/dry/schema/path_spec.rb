RSpec.describe Dry::Schema::Path do
  subject(:path) do
    Dry::Schema::Path.new(segments)
  end

  describe '#to_h' do
    let(:segments) do
      %i[foo bar 1 baz bar foo]
    end

    it 'returns a nested hash with an array placeholder' do
      expect(path.to_h).to eql(foo: { bar: { '1': { baz: { bar: { foo: [] } } } } })
    end
  end

  describe '#index' do
    let(:segments) do
      %i[foo bar 1 baz bar foo]
    end

    it 'returns index for a given key' do
      expect(path.index(:'1')).to be(2)
      expect(path.index(:baz)).to be(3)
    end
  end

  describe '#include?' do
    let(:segments) do
      %i[foo bar 1 baz bar foo]
    end

    it 'returns true if a path is within the source path' do
      other = Dry::Schema::Path.new(%i[foo bar])

      expect(path.include?(other)).to be(true)
    end

    it 'returns true if a path is the same as the source path' do
      other = Dry::Schema::Path.new(%i[foo bar 1 baz bar foo])

      expect(path.include?(other)).to be(true)
    end

    it 'returns false if a path has a different root' do
      other = Dry::Schema::Path.new(%i[something_else foo bar])

      expect(path.include?(other)).to be(false)
    end

    it 'returns false if a path is not within the source path' do
      other = Dry::Schema::Path.new(%i[foo something_else])

      expect(path.include?(other)).to be(false)
    end
  end
end
