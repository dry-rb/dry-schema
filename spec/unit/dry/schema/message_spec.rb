# frozen_string_literal: true

require "dry/schema/message"

RSpec.describe Dry::Schema::Message do
  let(:text) { "failed" }
  let(:path) { %i[user] }
  let(:meta) { {code: 123} }

  def msg(path: self.path, meta: self.meta)
    Dry::Schema::Message.new(text: text, predicate: :int?, path: path, input: nil, meta: meta)
  end

  describe "#<=>" do
    let(:child) { [*path, :age] }

    it "returns -1 when path is lower in hierarchy" do
      expect(msg <=> msg(path: child)).to be(-1)
    end

    it "returns 0 when path is the same" do
      expect(msg(path: child) <=> msg(path: child)).to be(0)
    end

    it "returns 1 when path is higher in hierarchy" do
      expect(msg(path: child) <=> msg).to be(1)
    end

    it "raises when paths have a different root" do
      expect { msg <=> msg(path: %i[address]) }
        .to raise_error(ArgumentError, "Cannot compare messages from different root paths")
    end
  end

  describe "#dump" do
    it "returns just the text when meta is empty" do
      expect(msg(meta: {}).dump).to eq(text)
    end

    it "returns the text and splatted meta when meta is not empty" do
      expect(msg.dump).to eq(meta.merge(text: text))
    end
  end

  describe "#to_h" do
    it "has arrays of strings for values when meta is empty" do
      expect(msg(meta: {}).to_h).to eq(path.first => [text])
    end

    it "has arrays of hashes for values when meta is empty" do
      expect(msg.to_h).to eq(path.first => [{text: text, **meta}])
    end
  end
end
