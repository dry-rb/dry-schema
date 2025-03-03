---
title: OpenAPI Schema
layout: gem-single
name: dry-schema
---

The `:open_api_schema` extension allows you to generate a valid [OpenAPI Schema](https://swagger.io/specification/v3/) from a `Dry::Schema`. This makes it straightforward to leverage tools like Swagger, which is popular for API documentation and testing.

```ruby
Dry::Schema.load_extensions(:open_api_schema)

UserSchema = Dry::Schema.JSON do
  required(:email).filled(:str?, min_size?: 8)
  optional(:favorite_color).filled(:str?, included_in?: %w[red green blue pink])
  optional(:age).filled(:int?)
end

UserSchema.open_api_schema 
# {
#   type: "object",
#   properties: {
#     email: {
#       type: "string",
#       minLength: 8
#     },
#     favorite_color: {
#       type: "string",
#       minLength: 1,
#       enum: %w[red green blue pink]
#     },
#     age: {
#       type: "integer"
#     }
#   },
#   required: ["email"]
# }
```

### Learn more

- [Official OpenAPI docs](https://spec.openapis.org/)
- [Swagger](https://swagger.io/docs/)
- [Integrate Swagger with your Rails app](https://github.com/rswag/rswag)

