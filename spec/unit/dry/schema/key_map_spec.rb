# frozen_string_literal: true

require "dry/schema/key_map"

RSpec.describe Dry::Schema::KeyMap do
  subject(:key_map) { Dry::Schema::KeyMap.new(keys) }

  context "with a flat list of keys" do
    let(:keys) { %i[id name email] }

    describe "#write" do
      it "creates a new full hash based on keys" do
        expect(key_map.write(id: 1, name: "Jane", email: "jane@doe.org"))
          .to eql(id: 1, name: "Jane", email: "jane@doe.org")
      end

      it "creates a new partial hash based on keys" do
        expect(key_map.write(name: "Jane")).to eql(name: "Jane")
      end

      it "does not choke on a non-hash input" do
        expect(key_map.write(nil)).to eql(Dry::Schema::EMPTY_HASH)
      end
    end

    describe "#each" do
      it "yields each key" do
        result = []

        key_map.each { |key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:id], Dry::Schema::Key[:name], Dry::Schema::Key[:email]]
        )
      end
    end

    describe "#stringified" do
      it "returns a key map with stringified keys" do
        result = []
        hash = {"id" => 1, "name" => "Jane", "email" => "jade@doe.org"}

        key_map.stringified.each { |key| key.read(hash) { |value| result << value } }

        expect(result).to eql([1, "Jane", "jade@doe.org"])
      end
    end

    describe "#to_dot_notation" do
      it "returns an array with dot-notation strings" do
        expect(key_map.to_dot_notation).to eql(%w[id name email])
      end
    end

    describe "#+" do
      let(:other) { Dry::Schema::KeyMap.new([:age, :address]) }
      let(:keys) { %i[id name] }

      it "merges two key maps" do
        expect((key_map + other).map(&:id)).to eql(%i[id name age address])
      end
    end

    describe "#inspect" do
      let(:keys) { %i[id name] }

      it "returns a string representation" do
        expect(key_map.inspect).to eql(<<-STR.strip)
          #<Dry::Schema::KeyMap[:id, :name]>
        STR
      end
    end
  end

  context "with a nested hash" do
    let(:keys) { [:id, :name, {contact: %i[email phone]}] }

    describe "#each" do
      it "yields each key and nested key map" do
        result = []

        key_map.each { |key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:id],
           Dry::Schema::Key[:name],
           Dry::Schema::Key::Hash[:contact, members: Dry::Schema::KeyMap[:email, :phone]]]
        )
      end
    end

    describe "#stringified" do
      it "returns a key map with stringified keys" do
        result = []

        hash = {
          "id" => 1,
          "name" => "Jane",
          "contact" => {"email" => "jade@doe.org", "phone" => 123}
        }

        key_map.stringified.each { |key| key.read(hash) { |value| result << value } }

        expect(result).to eql([1, "Jane", {"email" => "jade@doe.org", "phone" => 123}])
      end
    end

    describe "#to_dot_notation" do
      it "returns an array with dot-notation strings" do
        expect(key_map.to_dot_notation)
          .to eql(["id", "name", "contact.email", "contact.phone"])
      end
    end

    describe "#inspect" do
      it "returns a string representation" do
        expect(key_map.inspect).to eql(<<-STR.strip)
          #<Dry::Schema::KeyMap[:id, :name, {:contact=>[:email, :phone]}]>
        STR
      end
    end
  end

  context "with a nested array" do
    let(:keys) { [:title, [:tags, [:name, :count]]] }

    describe "#each" do
      it "yields each key and nested key map" do
        result = []

        key_map.each { |key| result << key }

        expect(result).to eql(
          [Dry::Schema::Key[:title],
           Dry::Schema::Key::Array[:tags, member: Dry::Schema::KeyMap[:name, :count]]]
        )
      end
    end

    describe "#stringified" do
      it "returns a key map with stringified keys" do
        result = []

        hash = {
          "title" => "Bohemian Rhapsody",
          "tags" => [
            {"name" => "queen", "count" => 312},
            {"name" => "classic", "count" => 423}
          ]
        }

        key_map.stringified.each { |key| key.read(hash) { |value| result << value } }

        expect(result).to eql(
          ["Bohemian Rhapsody",
           [{"name" => "queen", "count" => 312}, {"name" => "classic", "count" => 423}]]
          )
      end
    end

    describe "#to_dot_notation" do
      it "returns an array with dot-notation strings" do
        expect(key_map.to_dot_notation)
          .to eql(["title", "tags[].name", "tags[].count"])
      end
    end

    describe "#inspect" do
      it "returns a string representation" do
        expect(key_map.inspect).to eql(<<-STR.strip)
          #<Dry::Schema::KeyMap[:title, [:tags, [:name, :count]]]>
        STR
      end
    end
  end
end
