# frozen_string_literal: true

require 'dry-schema'

schema = Dry::Schema.Params do
  required(:email).filled

  required(:age).filled(:integer, gt?: 18)
end

result = schema.call('email' => '', 'age' => '18')
puts result.errors.messages.inspect
