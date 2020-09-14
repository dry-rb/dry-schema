# frozen_string_literal: true

RSpec.describe "Params / Macros / maybe" do
  context "with an array with hash schema as the member" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:data).maybe(array[Test::Info])
      end
    end

    before do
      Test::ID = Types::Integer.constrained(gt: 0)
      Test::Name = Types::String.constrained(format: /[a-z]+/)
      Test::Info = Types::Hash.schema(id: Test::ID, name: Test::Name)
    end

    it "passes when nil" do
      expect(schema.(data: nil)).to be_success
    end

    it "passes when empty array" do
      expect(schema.(data: [])).to be_success
    end

    it "passes when elements are valid hashes" do
      data = [{id: 1, name: "Jane"}, {id: 2, name: "John"}]

      expect(schema.(data: data)).to be_success
    end

    it "fails when non-array is passed" do
      expect(schema.(data: {}).errors.to_h).to eql(
        data: ["must be an array"]
      )
    end

    it "fails when an element is not a hash" do
      expect(schema.(data: ["oops"]).errors.to_h).to eql(
        data: {0 => ["must be a hash"]}
      )
    end

    it "fails when an element is not a hash matching the member schema" do
      data = [{id: 1, name: "Jane"}, {id: 0, name: "123"}]

      expect(schema.(data: data).errors.to_h).to eql(
        data: {1 => {id: ["must be greater than 0"], name: ["is in invalid format"]}}
      )
    end
  end

  context "with a nested hash" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:song).maybe(:hash) do
          required(:title).filled(:string)
          optional(:author).filled(:string)
        end
      end
    end

    it "passes when valid" do
      song = {"title" => "World", "author" => "Joe"}

      expect(schema.(song: song)).to be_success
    end

    it "fails when not valid" do
      song = {"title" => "", "author" => "Jane"}

      expect(schema.(song: song).errors.to_h).to eql(
        song: {title: ["must be filled"]}
      )
    end

    it "passes when nil" do
      expect(schema.(song: nil)).to be_success
    end
  end

  context "with a nested schema" do
    inner_schema = Dry::Schema.Params do
      required(:name).filled(:string)
    end

    schema = Dry::Schema.Params do
      required(:user).maybe(:hash, inner_schema)
    end

    it "passes when valid" do
      expect(schema.("user" => {name: "John"})).to be_success
    end

    it "passes when valid and keys are strings" do
      expect(schema.("user" => {"name" => "John"})).to be_success
    end

    it "fails when not valid" do
      expect(schema.("user" => {"name" => 1}).errors.to_h).to eq(user: {name: ["must be a string"]})
    end

    it "passes when optional argument is missing" do
      expect(schema.("user" => nil)).to be_success
    end
  end
end
