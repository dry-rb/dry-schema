# frozen_string_literal: true

RSpec.describe Dry::Schema::JSON, "#info" do
  before do
    Dry::Schema.load_extensions(:info)
  end

  subject(:schema) do
    Dry::Schema.JSON do
      required(:email).filled(:string)
      optional(:age).filled(:integer)

      required(:roles).array(:hash) do
        required(:name).filled(:string)
        optional(:desc).filled(:string)
      end

      optional(:address).hash do
        required(:street).filled(:string)
        required(:zipcode).filled(:string)
        required(:city).filled(:string)
        optional(:phone).filled(:string)
      end
    end
  end

  let(:info) do
    {
      keys: {
        email: {
          required: true,
          type: "string"
        },
        age: {
          required: false,
          type: "integer"
        },
        roles: {
          required: true,
          type: "array",
          member: {
            keys: {
              name: {
                required: true,
                type: "string"
              },
              desc: {
                required: false,
                type: "string"
              }
            }
          }
        },
        address: {
          required: false,
          type: "hash",
          keys: {
            street: {
              required: true,
              type: "string"
            },
            zipcode: {
              required: true,
              type: "string"
            },
            city: {
              required: true,
              type: "string"
            },
            phone: {
              required: false,
              type: "string"
            }
          }
        }
      }
    }
  end

  it "returns info hash" do
    expect(schema.info).to eql(info)
  end

  context "with typed array schema" do
    let(:schema) do
      Dry::Schema.Params do
        required(:opt1).filled(Types::Array)
        required(:opt2).filled(Types::Array(:string))
        required(:opt3).filled(Types::Array(:integer))
        required(:opt4).filled(Types::Array(:bool))
      end
    end

    let(:info) do
      {
        keys: {
          opt1: {
            required: true,
            type: "array"
          },
          opt2: {
            required: true,
            type: "array",
            member: "string"
          },
          opt3: {
            required: true,
            type: "array",
            member: "integer"
          },
          opt4: {
            required: true,
            type: "array",
            member: "bool"
          }
        }
      }
    end

    it { expect(schema.info).to eql(info) }
  end

  describe "inferring types" do
    {
      array: "array",
      bool: "bool",
      date: "date",
      date_time: "date_time",
      decimal: "float",
      float: "float",
      hash: "hash",
      integer: "integer",
      nil: "nil",
      string: "string",
      time: "time"
    }.each do |type_spec, type_name|
      it "infers '#{type_name}' from '#{type_spec}'" do
        expect(Dry::Schema.define { required(:key).value(type_spec) }.info).to eql(
          keys: {key: {required: true, type: type_name}}
        )
      end
    end
  end
end
