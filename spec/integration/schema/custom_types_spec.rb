# frozen_string_literal: true

RSpec.describe "Registering custom types" do
  let(:result) do
    schema.call(params)
  end

  let(:container_without_types) do
    Dry::Schema::TypeContainer.new
  end

  let(:container_with_types) do
    Dry::Schema::TypeContainer.new
  end

  let(:params) do
    {
      email: "some@body.abc",
      age: "  I AM NOT THAT OLD "
    }
  end

  before do
    container_with_types.register(
      "params.trimmed_string",
      Types::Strict::String.constructor(&:strip).constructor(&:downcase)
    )

    stub_const("ContainerWithoutTypes", container_without_types)
    stub_const("ContainerWithTypes", container_with_types)
  end

  context "class-based definition" do
    subject(:schema) { klass.new }

    context "custom type is not registered" do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::Params
          define do
            config.types = ContainerWithoutTypes

            required(:email).filled(:string)
            required(:age).filled(:trimmed_string)
          end
        end
      end

      it "raises exception that nothing is registered with the key" do
        expect { result }.to raise_exception(Dry::Container::KeyError)
      end
    end

    context "custom type is registered" do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::Params
          define do
            config.types = ContainerWithTypes

            required(:email).filled(:string)
            required(:age).filled(:trimmed_string)
          end
        end
      end

      it "does not raise any exceptions" do
        expect { result }.not_to raise_exception
      end

      it "coerces the type" do
        expect(result[:age]).to eql("i am not that old")
      end
    end

    context "maybe decimal" do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::JSON
          define do
            required(:number).maybe(Types::JSON::Decimal | Types::Params::Nil)
          end
        end
      end

      let(:params) do
        {number: "19.3"}
      end

      it "coerces the type" do
        expect(result[:number]).to eql(BigDecimal("19.3"))
      end
    end

    context "filled string" do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::JSON
          define do
            required(:string).filled(
              Types::Strict::String.constrained(format: /foo/) |
              Types::Strict::String.constrained(format: /bar/)
            )
          end
        end
      end

      let(:params) do
        {string: "foo"}
      end

      it "coerces the type" do
        expect(result[:string]).to eql("foo")
      end
    end
  end

  context "DSL-based definition" do
    context "custom type is not registered" do
      subject(:schema) do
        Dry::Schema.Params do
          config.types = ContainerWithoutTypes

          required(:email).filled(:string)
          required(:age).filled(:trimmed_string)
        end
      end

      it "raises exception that nothing is registered with the key" do
        expect { result }.to raise_exception(Dry::Container::KeyError)
      end
    end

    context "custom type is registered" do
      subject(:schema) do
        Dry::Schema.Params do
          config.types = ContainerWithTypes

          required(:email).filled(:string)
          required(:age).filled(:trimmed_string)
        end
      end

      it "does not raise any exceptions" do
        expect { result }.not_to raise_exception
      end

      it "coerces the type" do
        expect(result[:age]).to eql("i am not that old")
      end

      context "nested schema" do
        subject(:schema) do
          Dry::Schema.Params do
            config.types = ContainerWithTypes

            required(:user).hash do
              required(:age).filled(:trimmed_string)
            end
          end
        end

        let(:params) { {user: {age: "  I AM NOT THAT OLD "}} }

        specify do
          expect(result[:user][:age]).to eql("i am not that old")
        end
      end

      context "custom constructor" do
        subject(:schema) do
          Dry::Schema.Params do
            config.types = ContainerWithTypes
            optional(:date).maybe(:calendar_day)
          end
        end

        let(:calendar_date) do
          Class.new(::Date) do
            def self.parse(date)
              mon, mday = Date._iso8601(date).values_at(:mon, :mday)
              raise ArgumentError, "invalid ISO8601 calendar day string, expected format \"--MM-DD\"" unless mon && mday

              new(2000, mon, mday)
            end
          end
        end

        before do
          stub_const("CalendarDate", calendar_date)

          container_with_types.register(
            :calendar_day,
            Types::Strict(CalendarDate).constructor(CalendarDate.method(:parse))
          )
        end

        let(:params) do
          {"date" => "--02-09"}
        end

        specify do
          expect(result).to be_success
          expect(result[:date]).to be_a(CalendarDate)
          expect(result[:date].strftime("--%m-%d")).to eq("--02-09")
        end
      end
    end
  end

  context "error handling" do
    subject(:schema) { klass.new }

    before do
      container_with_types.register(
        "params.string_or_integer",
        Types::Strict::String | Types::Strict::Decimal
      )
    end

    let(:klass) do
      class Test::CustomTypeSchema < Dry::Schema::Params
        define do
          config.types = ContainerWithTypes

          required(:age).filled(:string_or_integer)
        end
      end
    end

    let(:params) {
      {
        age: 4.5
      }
    }

    before do
      klass.definition.configure { |config| config.messages.backend = backend }
    end

    context "with YAML backend" do
      let(:backend) { :yaml }

      it "provides a valid error message" do
        expect(result.errors[:age])
          .to include "must be a string or must be a decimal"
      end
    end

    context "with I18n backend" do
      let(:backend) { :i18n }

      it "provides a valid error message" do
        expect(result.errors[:age])
          .to include "must be a string or must be a decimal"
      end
    end
  end
end
