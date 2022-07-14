# frozen_string_literal: true

RSpec.describe "inheriting from a parent and extending its rules" do
  let(:parent) do
    Dry::Schema.define do
      required(:foo).filled(:hash?)
    end
  end

  subject(:child) do
    Dry::Schema.define(parent: [parent]) do
      required(:foo).hash do
        required(:qux).hash do
          required(:bar).filled(:string)
        end
      end
    end
  end

  it "correctly eliminates nested unknown keys" do
    expect(
      child.call({foo: {qux: {bar: "baz", hello: "there"}}}).to_h
    ).to eq({foo: {qux: {bar: "baz"}}})
  end
end
