---
title: JSON
layout: gem-single
name: dry-schema
---

To validate JSON data structures, you can use `JSON` schemas. The difference between `Params` and `JSON` is coercion logic. Refer to [dry-types](/gems/dry-types/1.0/built-in-types) documentation for more information about supported JSON coercions.

### Examples

```ruby
schema = Dry::Schema.JSON do
  required(:email).filled(:string)
  required(:age).value(:integer, gt?: 18)
end

errors = schema.call('email' => '', 'age' => 18).errors.to_h

puts errors.inspect
# {
#   :email => ["must be filled"],
#   :age => ["must be greater than 18"]
# }
```

> **Notice** that JSON schemas are suitable for checking hash objects *exclusively*. There's an outstanding [issue](https://github.com/dry-rb/dry-schema/issues/23) about making it work with any JSON-compatible input.
