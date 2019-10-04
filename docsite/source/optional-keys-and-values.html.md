---
title: Optional keys and values
layout: gem-single
name: dry-schema
---

We make a clear distinction between specifying an optional **key** and an optional **value**. This gives you a way of being very specific about validation rules. You can define a schema which gives you precise errors when a key is missing or key is present but the value is `nil`.

This also comes with the benefit of being explicit about the type expectation. In the example below we explicitly state that `:age` _can be omitted_ or if present it _must be an integer_ and it _must be greater than 18_.

### Optional keys

You can define which keys are optional and define rules for their values:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  optional(:age).filled(:integer, gt?: 18)
end

errors = schema.call(email: 'jane@doe.org').errors

puts errors.to_h.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 17).errors

puts errors.to_h.inspect
# { :age => ["must be greater than 18"] }
```

### Optional values

When it is allowed for a given value to be `nil` you can use `maybe` macro:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  optional(:age).maybe(:integer, gt?: 18)
end

errors = schema.call(email: 'jane@doe.org', age: nil).errors

puts errors.to_h.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 19).errors

puts errors.to_h.inspect
# {}

errors = schema.call(email: 'jane@doe.org', age: 17).errors

puts errors.to_h.inspect
# { :age => ["must be greater than 18"] }
```
