---
title: Params
layout: gem-single
name: dry-schema
---

Probably the most common use case is to validate HTTP params. This is a special kind of a validation for a couple of reasons:

- The input is a hash with stringified keys
- The input can include values that are strings, hashes or arrays
- Prior to validation, we need to symbolize keys and coerce values based on the information in a schema

For that reason, `dry-schema` ships with `Params` schemas:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  required(:age).filled(:integer, gt?: 18)
end

errors = schema.call('email' => '', 'age' => '18').errors

puts errors.to_h.inspect
# {
#   :email => ["must be filled"],
#   :age => ["must be greater than 18"]
# }
```

> Params-specific value coercion is handled by the hash type from `dry-types`. It is built automatically for you based on the type specs and used prior to applying the validation rules

### Handling empty strings

Your schema will automatically coerce empty strings to `nil`, provided that you allow a value to be nil:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  required(:age).maybe(:integer)
  required(:tags).maybe(:array)
end

result = schema.call('email' => 'jane@doe.org', 'age' => '', 'tags' => '')

puts result.to_h
# {:email=>'jane@doe.org', :age=>nil, :tags=>nil}
```

Your schema will automatically coerce empty strings **to an empty array**:

```ruby
schema = Dry::Schema.Params do
  required(:tags).value(:array)
end

result = schema.call('tags' => '')

puts result.to_h
# {:email=>'jane@doe.org', :age=>nil, :tags=>[]}
```
