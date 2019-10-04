---
title: Custom types
layout: gem-single
name: dry-schema
---

You would often use `dry-schema` to transform your input. Let's say, you want to remove any whitespace characters at the beginning and the end of the string. You would probably make a type like this and use it in your schema:

```ruby
StrippedString = Types::String.constructor(&:strip)

Schema = Dry::Schema.Params do
  required(:some_number).filled(:integer)
  required(:my_string).filled(StrippedString)
end
```

However, you might find it inconvenient to use constants instead of symbols, especially if you want to use the type throughout the project. You might want to use it like this:

```ruby
Schema = Dry::Schema.Params do
  required(:some_number).filled(:integer)
  required(:my_string).filled(:stripped_string)
end
```

Version `1.2` introduced a solution that would let you achieve that. You'll need to build a custom type container — an instance `Dry::Schema::TypeContainer`, register your types, and pass it to `config.types`.

```ruby
StrippedString = Types::String.constructor(&:strip)

TypeContainer = Dry::Schema::TypeContainer.new
TypeContainer.register('params.stripped_string', StrippedString)

Schema = Dry::Schema.Params do
  config.types = TypeContainer
  required(:some_number).filled(:integer)
  required(:my_string).filled(:stripped_string)
end
```

Each schema processor uses different namespaces, so you'll have to keep it in mind when chosing the key.

- Use `params.my_type` if you want to register the type for `Dry::Schema::Params`
- Use `nominal.my_type` if you want to register the type for `Dry::Schema::Processor`
- Use `json.my_type` if you want to register the type for `Dry::Schema::JSON`
