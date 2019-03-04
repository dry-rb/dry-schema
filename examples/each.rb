# frozen_string_literal: true

require 'dry-schema'

schema = Dry::Schema.define do
  required(:phone_numbers).value(:array?).each(:str?)
end

errors = schema.call(phone_numbers: '').messages

puts errors.inspect

errors = schema.call(phone_numbers: ['123456789', 123456789]).messages

puts errors.inspect
