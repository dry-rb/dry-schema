# frozen_string_literal: true

RSpec.describe Dry::Schema::JSON, "#info" do
  before do
    Dry::Schema.load_extensions(:info)
  end

  subject(:schema) do
    Dry::Schema.JSON do
      required(:email).filled(:string)
      optional(:age).maybe(:integer)

      required(:roles).array(:hash) do
        required(:name).filled(:string)
        optional(:desc).filled(:string)
      end

      optional(:address).hash do
        required(:street).filled(:string)
        optional(:zipcode).filled(:string)
        required(:city).filled(:string)
        optional(:phone).maybe(:string)
      end
    end
  end

  let(:info) do
    {
      keys: {
        email: {
          nullable: false,
          required: true,
          type: "string"
        },
        age: {
          nullable: true,
          required: false,
          type: "integer"
        },
        roles: {
          nullable: false,
          required: true,
          type: "array",
          member: {
            keys: {
              name: {
                nullable: false,
                required: true,
                type: "string"
              },
              desc: {
                nullable: false,
                required: false,
                type: "string"
              }
            }
          }
        },
        address: {
          nullable: false,
          required: false,
          type: "hash",
          keys: {
            street: {
              nullable: false,
              required: true,
              type: "string"
            },
            zipcode: {
              nullable: false,
              required: false,
              type: "string"
            },
            city: {
              nullable: false,
              required: true,
              type: "string"
            },
            phone: {
              nullable: true,
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
            nullable: false,
            required: true,
            type: "array"
          },
          opt2: {
            nullable: false,
            required: true,
            type: "array",
            member: "string"
          },
          opt3: {
            nullable: false,
            required: true,
            type: "array",
            member: "integer"
          },
          opt4: {
            nullable: false,
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
          keys: {key: {nullable: false, required: true, type: type_name}}
        )
      end
    end
  end
end
