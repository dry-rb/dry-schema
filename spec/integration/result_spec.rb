# frozen_string_literal: true

RSpec.describe Dry::Schema::Result do
  subject(:result) { schema.(input) }

  let(:schema) { Dry::Schema.define { required(:name).filled(size?: 2..4) } }

  context "with frozen input" do
    let(:input) { {name: "Jane"}.freeze }

    it "does not raise errors" do
      expect { result }.not_to raise_error
    end
  end

  context "with valid input" do
    let(:input) { {name: "Jane"} }

    it "is successful" do
      expect(result).to be_successful
    end

    it "is not a failure" do
      expect(result).to_not be_failure
    end

    it "coerces to validated hash" do
      expect(result.to_h).to eql(name: "Jane")
    end

    describe "#inspect" do
      it "returns a string representation" do
        expect(result.inspect).to eql(<<-STR.strip)
          #<Dry::Schema::Result{:name=>"Jane"} errors={} path=[]>
        STR
      end
    end

    describe "#messages" do
      it "returns an empty hash" do
        expect(result.messages).to be_empty
      end
    end
  end

  context "with invalid input" do
    let(:input) { {name: ""} }

    it "is not successful" do
      expect(result).to_not be_successful
    end

    it "is failure" do
      expect(result).to be_failure
    end

    it "coerces to validated hash" do
      expect(result.to_h).to eql(name: "")
    end

    describe "#inspect" do
      it "returns a string representation" do
        expect(result.inspect).to eql(<<-STR.strip)
          #<Dry::Schema::Result{:name=>""} errors={:name=>["must be filled"]} path=[]>
        STR
      end
    end

    context "when scoped" do
      let(:schema) do
        Dry::Schema.define do
          required(:account).schema do
            required(:name).schema do
              required(:first).filled(:string)
            end
          end
        end
      end

      let(:input) { {account: {name: {first: "ojab"}}} }

      describe "#inspect" do
        it "returns a string representation" do
          expect(result.at([:account, :name]).inspect).to eql(<<-STR.strip)
            #<Dry::Schema::Result{:first=>"ojab"} errors={} path=[:account, :name]>
          STR
        end
      end
    end

    describe "#messages" do
      it "returns a hash with error messages" do
        expect(result.messages).to eql(
          name: ["must be filled", "length must be within 2 - 4"]
        )
      end

      it "with full: true returns full messages" do
        expect(result.messages(full: true)).to eql(
          name: ["name must be filled", "name length must be within 2 - 4"]
        )
      end
    end

    describe "#errors" do
      let(:input) { {name: ""} }

      it "returns failure messages" do
        expect(result.errors).to eql(name: ["must be filled"])
      end
    end

    describe "#hints" do
      let(:input) { {name: ""} }

      it "returns hint messages" do
        expect(result.hints).to eql(name: ["length must be within 2 - 4"])
      end
    end

    describe "#message_set" do
      it "returns message set" do
        expect(result.message_set.to_h).to eql(
          name: ["must be filled", "length must be within 2 - 4"]
        )
      end
    end
  end
end
