# frozen_string_literal: true

require 'json'
require 'dry-schema'

schema = Dry::Schema.JSON do
  required(:email).filled

  required(:age).filled(:integer, gt?: 18)
end

result = schema.call(JSON.parse('{"email": "", "age": "18"}'))

puts result.errors.messages.inspect
