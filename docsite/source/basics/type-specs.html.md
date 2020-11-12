---
title: Type specs
layout: gem-single
name: dry-schema
---

^WARNING
Starting from dry-schema 2.0 type specs will be obligatory arguments. ie `filled(:string)` will work but `filled` without a type spec will raise an argument error.
^

To define what the expected type of a value is, you should use type specs. All macros support type specs as the first argument, whenever you pass a symbol that doesn't end with a question mark, or you explicitly pass in an instance of a `Dry::Types::Type` object, it will be set as the type.

> Whenever you define a type spec, `dry-schema` will infer a type-check predicate. ie:
> * `:string` => `str?`
> * `:integer` => `:int?`
> * `:array` => `:array?`
> * etc.
>
> These predicates will be *prepended* to the list of the predicates you specified (if any).

### Using type identifiers

In most common cases you can use symbols that identify built-in types. The types are resolved from type registry which is configured for individual schemas. For example `Dry::Schema::Params` has its type registry configured to use `Params` types by default. This means that if you specify `:integer` as the type, then `Dry::Schema::Types::Params::Integer` will be used as the resolved type.

```ruby
UserSchema = Dry::Schema.Params do
  # expands to: `int? & gt?(18)`
  required(:age).value(:integer, gt?: 18)
end
```

### Using arrays with member types

To define an array with a member, you can use a shortcut method `array`. Here's an example of an array with `:integer` set as its member type:

``` ruby
UserSchema = Dry::Schema.Params do
  # expands to: `array? & each { int? } & size?(3)`
  required(:nums).value(array[:integer], size?: 3)
end
```

### Using custom types

You are not limited to the built-in types. The DSL accepts any `Dry::Types::Type` object:

```ruby
module Types
  include Dry::Types()

  StrippedString = Types::String.constructor(&:strip)
end

UserSchema = Dry::Schema.Params do
  # expands to: `str? & min_size?(10)`
  required(:login_time).value(StrippedString, min_size?: 10)
end
```

### Learn more

- [Built-in predicates](docs::basics/built-in-predicates)
- [Working with schemas](docs::basics/working-with-schemas)
