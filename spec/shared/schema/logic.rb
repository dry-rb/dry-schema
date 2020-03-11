# frozen_string_literal: true

RSpec.shared_examples "schema logic operators" do
  subject(:schema) do
    Dry::Schema.public_send(schema_method) do
      required(:user).hash(Test::Operation)
    end
  end

  let(:left) do
    Dry::Schema.define { required(:age).value(:integer) }
  end

  let(:right) do
    Dry::Schema.define { required(:name).value(:string) }
  end

  before do
    Test::Operation = left.public_send(operator, right)
  end

  describe "#and" do
    let(:operator) { :and }

    it "composes schemas using conjunction" do
      expect(schema.(user: {age: 36, name: "Jane"})).to be_success

      expect(schema.(user: {age: "36", name: "Jane"}).errors.to_h).to eql(
        user: {age: ["must be an integer"]}
      )
    end
  end

  describe "#or" do
    let(:operator) { :or }

    it "composes schemas using disjunction" do
      expect(schema.(user: {age: 36, name: "Jane"})).to be_success
      expect(schema.(user: {age: 36})).to be_success
      expect(schema.(user: {name: "Jane"})).to be_success

      expect(schema.(user: {age: "36", name: :Jane}).errors.to_h).to eql(
        user: {or: [{age: ["must be an integer"]}, {name: ["must be a string"]}]}
      )
    end
  end

  describe "#then" do
    let(:operator) { :then }

    it "composes schemas using implication" do
      expect(schema.(user: {age: 36, name: "Jane"})).to be_success
      expect(schema.(user: {age: "36", name: :Jane})).to be_success

      expect(schema.(user: {age: 36, name: :Jane}).errors.to_h).to eql(
        user: {name: ["must be a string"]}
      )
    end
  end

  describe "#xor" do
    let(:operator) { :xor }

    it "composes schemas using exclusive disjunction" do
      expect(schema.(user: {age: 36, name: :Jane})).to be_success
      expect(schema.(user: {age: "36", name: "Jane"})).to be_success
    end
  end
end
