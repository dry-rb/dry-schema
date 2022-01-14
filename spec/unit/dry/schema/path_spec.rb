# frozen_string_literal: true

RSpec.describe Dry::Schema::Path do
  subject(:path) do
    Dry::Schema::Path.new(segments)
  end

  describe "#to_h" do
    let(:segments) do
      %i[foo bar 1 baz bar foo]
    end

    it "returns a nested hash with an array placeholder" do
      expect(path.to_h).to eql(foo: {bar: {"1": {baz: {bar: {foo: []}}}}})
    end
  end

  describe "#include?" do
    let(:segments) do
      %i[foo bar 1 baz bar foo]
    end

    it "returns true if a path is within the source path" do
      other = Dry::Schema::Path.new(%i[foo bar])

      expect(path.include?(other)).to be(true)
    end

    it "returns true if a path is the same as the source path" do
      other = Dry::Schema::Path.new(%i[foo bar 1 baz bar foo])

      expect(path.include?(other)).to be(true)
    end

    it "returns false if a path has a different root" do
      other = Dry::Schema::Path.new(%i[something_else foo bar])

      expect(path.include?(other)).to be(false)
    end

    it "returns false if a path is not within the source path" do
      other = Dry::Schema::Path.new(%i[foo something_else])

      expect(path.include?(other)).to be(false)
    end

    context "with array item" do
      it "returns true when path points to the root element with nested elements that contains errors" do
        left = Dry::Schema::Path.new([:foo, 0, :bar, 1, :baz])
        right = Dry::Schema::Path.new([:foo, 0])

        expect(left.include?(right)).to be(true)
      end

      it "returns false when right-side points to another element of the same array" do
        left = Dry::Schema::Path.new([:foo, 0, :bar, 1, :baz])
        right = Dry::Schema::Path.new([:foo, 1])

        expect(left.include?(right)).to be(false)
      end

      it "doens't blow up stack on specific input" do
        left = Dry::Schema::Path.new([:data, :relationships, :data])
        right = Dry::Schema::Path.new([:data, :relationships, :replacements, :data, 1])

        expect(left.include?(right)).to be(false)
      end
    end
  end

  describe "#&" do
    let(:segments) do
      %i[user address street]
    end

    it "returns a new path with the common segment as the root" do
      other = Dry::Schema::Path.new(%i[user address city])
      root = Dry::Schema::Path.new(%i[user address])

      expect(path & other).to eql(root)
    end

    it "returns empty path if other is not included in the source" do
      other = Dry::Schema::Path.new(%i[foo baz qux])

      expect(path & other).to eql(Dry::Schema::Path.new([]))
    end
  end

  describe "#<=>" do
    let(:paths) do
      [
        %i[a b d],
        %i[b],
        %i[a b c],
        [],
        %i[a b]
      ].map { |path| Dry::Schema::Path[path] }
    end

    it "sorts alphabetically, shortest paths first" do
      expect(paths.sort.map { |path| path.keys.join(".") }).to eq(["", "a.b", "a.b.c", "a.b.d", "b"])
    end
  end
end
