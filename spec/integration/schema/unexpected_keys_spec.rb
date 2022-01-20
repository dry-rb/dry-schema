# frozen_string_literal: true

RSpec.describe Dry::Schema, "unexpected keys" do
  subject(:schema) do
    Dry::Schema.define do
      config.validate_keys = true

      required(:name).filled(:string)
      required(:ids).filled(:array).each(:integer)

      required(:address).hash do
        required(:city).filled(:string)
        required(:zipcode).filled(:string)
      end

      required(:roles).array(:hash) do
        required(:name).filled(:string)
        required(:expires_at).value(:date)
      end
    end
  end

  it "adds error messages about unexpected keys" do
    input = {
      foo: "unexpected",
      name: "Jane",
      ids: [1, 2, 3, 4],
      qux: [],
      quux: [{}],
      hoge: {},
      address: {bar: "unexpected", baz: [1], city: "NYC", zipcode: "1234"},
      roles: [
        {name: "admin", expires_at: Date.today},
        {name: "editor", foo: "unexpected", expires_at: Date.today}
      ],
      am: "John",
      city: "LA"
    }

    expect(schema.(input).errors.to_h)
      .to eql(
        foo: ["is not allowed"],
        qux: ["is not allowed"],
        quux: ["is not allowed"],
        hoge: ["is not allowed"],
        address: {bar: ["is not allowed"], baz: ["is not allowed"]},
        roles: {1 => {foo: ["is not allowed"]}},
        am: ["is not allowed"],
        city: ["is not allowed"]
      )
  end

  it "is treated as a failure when passed unexpected keys" do
    input = {
      foo: "unexpected",
      name: "Jane",
      ids: [1, 2, 3, 4],
      address: {bar: "unexpected", city: "NYC", zipcode: "1234"},
      roles: [
        {name: "admin", expires_at: Date.today},
        {name: "editor", foo: "unexpected", expires_at: Date.today}
      ]
    }

    expect(schema.(input)).to be_failure
  end

  it "supports meta tags" do
    schema = Dry::Schema.define do
      config.validate_keys = true
      config.messages.load_paths << "#{SPEC_ROOT}/fixtures/locales/pl.yml"
      config.messages.default_locale = :pl

      required(:title).filled
    end

    expect(schema.(wrong_key: nil).errors(full: true).to_h)
      .to eq({wrong_key: [{code: "nieoczekiwany_klucz", text: "wrong_key Podano nieoczekiwany klucz"}],
              title: [code: "brak_klucza", text: "title nie został podany"]})
  end

  context "with an array validation" do
    subject(:schema) do
      Dry::Schema.define do
        config.validate_keys = true

        required(:name).filled(:string)
        optional(:tags).array(:string)
      end
    end

    it "adds error messages" do
      input = {name: "", tags: ["red", 123]}
      expect(schema.(input).errors.to_h)
        .to eql(
          name: ["must be filled"],
          tags: {1 => ["must be a string"]}
        )
    end

    it "doesn't add the unexpected key error message when the type is wrong" do
      schema = Dry::Schema.define do
        config.validate_keys = true

        required(:pets).array(:hash) do
          required(:name).filled(:string)
        end
      end

      expect(schema.(foo: "unexpected", pets: "a string").errors.to_h)
        .to eql(
          foo: ["is not allowed"],
          pets: ["must be an array"]
        )
    end

    context "with a nested maybe hash validator" do
      subject(:schema) do
        Dry::Schema.define do
          config.validate_keys = true

          required(:locations).array(:hash) do
            required(:feedback_location).maybe(:hash) do
              required(:lat).filled(:float)
              required(:lng).filled(:float)
            end
          end
        end
      end

      it "doesn't add error messages when there are no unexpected keys" do
        expect(schema.(locations: [{feedback_location: nil}]).errors.to_h).to eq({})
      end
    end

    context "with a non-nested maybe hash validator" do
      subject(:schema) do
        Dry::Schema.define do
          config.validate_keys = true

          required(:feedback_location).maybe(:hash) do
            required(:lat).filled(:float)
            required(:lon).filled(:float)
          end
        end
      end

      it "doesn't add error messages when there are no unexpected keys" do
        expect(schema.(feedback_location: nil).errors.to_h).to eq({})
      end
    end
  end
end
