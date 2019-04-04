# frozen_string_literal: true

require 'dry-schema'

schema = Dry::Schema.define do
  required(:phone_numbers).value(:array).each(:string)
end

result = schema.call(phone_numbers: '')
puts result.errors.messages.inspect

result = schema.call(phone_numbers: ['123456789', 123456789])
puts result.errors.messages.inspect
