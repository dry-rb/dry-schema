# frozen_string_literal: true

require "dry-schema"

schema = Dry::Schema.define do
  required(:email).filled(:string)

  required(:age).filled(:int?, gt?: 18)
end

result = schema.call(email: "jane@doe.org", age: 19)
puts result.to_h

result = schema.call(email: nil, age: 19)
puts result.errors.messages.inspect
