---
title: Hints
layout: gem-single
name: dry-schema
---

In addition to error messages, you can also access hints, which are generated from your rules. While `errors` tell you which predicate checks failed, `hints` tell you which additional predicate checks *were not evaluated* because an earlier predicate failed:

```ruby
# enable :hints

Dry::Schema.load_extensions(:hints)

schema = Dry::Schema.Params do
  required(:email).filled(:string)
  required(:age).filled(:integer, gt?: 18)
end

result = schema.call(email: 'jane@doe.org', age: '')
result.hints.to_h

# {:age=>['must be greater than 18']}

result = schema.call(email: 'jane@doe.org', age: '')

result.errors.to_h
# {:age=>['must be filled']}

result.hints.to_h
# {:age=>['must be greater than 18']}
# hints takes the same options as errors:

result.hints(full: true)
# {:age=>['age must be greater than 18']}
```

You can also use `messages` to get a combination of both errors and hints:

```ruby
result = schema.call(email: 'jane@doe.org', age: '')
result.messages.to_h
# {:age=>["must be filled", "must be greater than 18"]}
```

### Learn more

- [Customizing messages](docs::error-messages)
