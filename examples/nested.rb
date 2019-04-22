# frozen_string_literal: true

require 'dry-schema'

schema = Dry::Schema.define do
  required(:address).schema do
    required(:city).filled(min_size?: 3)

    required(:street).filled

    required(:country).schema do
      required(:name).filled
      required(:code).filled
    end
  end
end

result = schema.call({})
puts result.errors.messages.inspect

result = schema.call(address: { city: 'NYC' })
puts result.errors.messages.inspect
