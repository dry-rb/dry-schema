# frozen_string_literal: true

RSpec.describe "inheriting from a parent and extending its rules" do
  context "one parent" do
    let(:parent) do
      Dry::Schema.define do
        required(:foo).filled(:hash?)
      end
    end

    let(:child) do
      Dry::Schema.define(parent: [parent]) do
        required(:foo).hash do
          required(:bar).hash do
            required(:baz).filled(:string)
          end
        end
      end
    end

    it "correctly eliminates nested unknown keys" do
      expect(
        child.call({foo: {bar: {baz: "baz", hello: "there"}}}).to_h
      ).to eq({foo: {bar: {baz: "baz"}}})
    end
  end

  context "two parents" do
    let(:parent_2) do
      Dry::Schema.JSON do
        required(:foo).hash do
          required(:bar).hash do
            required(:baz).filled(:hash)
            # required(:qux).filled(:hash)
          end
          required(:last).hash do
            required(:not).filled(:array).value(array[:string])
            required(:least).filled(:string)
          end
        end
      end
    end

    let(:parent_1) do
      Dry::Schema.JSON do
        required(:foo).filled.hash do
          required(:bar).hash do
            required(:baz).hash do
              required(:hey).filled(:hash)
            end
            required(:qux).hash do
              required(:hello).hash do
                required(:wow).value(:string, eql?: "a")
                required(:such).value(:string, eql?: "cool")
                required(:amaze).value(array[:string], size?: 1)
              end
              required(:my).hash do
                required(:wow).value(:string, eql?: "b")
                required(:such).value(:string, eql?: "cool")
                required(:amaze).value(array[:string], size?: 1)
              end
              required(:friend).hash do
                required(:wow).filled(eql?: "c")
                required(:such).filled(eql?: "cool")
                required(:amaze).value(array[:string], size?: 1)
              end
            end
          end
          required(:last).filled.hash do
            required(:not).value(:array, eql?: ["rad"])
            required(:least).value(:string, eql?: "done")
          end
        end
      end
    end

    let(:child) do
      Dry::Schema.JSON(parent: [parent_2, parent_1])
    end

    it "correctly joins nested hashes" do
      attrs = {
        foo: {
          bar: {
            baz: {hey: {some: "hash"}},
            qux: {
              hello: {wow: "a", such: "cool", amaze: ["yup"]},
              my: {wow: "b", such: "cool", amaze: ["yep"]},
              friend: {wow: "c", such: "cool", amaze: ["yip"]}
            }
          },
          last: {not: ["rad"], least: "done"}
        }
      }

      result = child.call(attrs)
      expect(result).to be_success
      expect(result.to_h).to eq(attrs)
    end
  end
end
