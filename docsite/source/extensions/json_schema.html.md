---
title: JSON Schema
layout: gem-single
name: dry-schema
---

The `:json_schema` extension allows you to generate a valid [JSON Schema](https://json-schema.org/) from a `Dry::Schema`. JSON Schema is a widely used standard, so this unlocks many possibilities.

```ruby
Dry::Schema.load_extensions(:json_schema)

UserSchema = Dry::Schema.JSON do
  required(:email).filled(:str?, min_size?: 8)
  optional(:favorite_color).filled(:str?, included_in?: %w[red green blue pink])
  optional(:age).filled(:int?)
end

UserSchema.json_schema 
# {
#   "type": "object",
#   "properties": {
#     "email": {
#       "type": "string",
#       "minLength": 8
#     },
#     "favorite_color": {
#       "type": "string",
# .     "enum": ["red", "green", "blue", "pink"]
#     },
#     "age": {
#       "type": "integer"
#     },
#   },
#   "required": ["email"] 
# }
```

### Learn more

- [Official JSON Schema docs](https://json-schema.org/)
- [Auto-generate forms with React + JSON Schema](https://github.com/rjsf-team/react-jsonschema-form))
- [Integrate with other languages more easily](https://json-schema.org/implementations.html)

