---
title: Macros
layout: gem-single
name: dry-schema
---

Defining rules using blocks is very flexible and powerful; however, in most common cases repeatedly defining the same rules leads to boilerplate code. That's why `dry-schema`'s DSL provides convenient macros to reduce that boilerplate. Every macro can be expanded to its block-based equivalent.

This document describes available built-in macros.

### value

Use it to quickly provide a list of all predicates that will be `AND`-ed automatically:

```ruby
Dry::Schema.Params do
  # expands to `required(:age) { int? & gt?(18) }`
  required(:age).value(:integer, gt?: 18)
end
```

Predicates passed as an array will be `OR`-ed automatically:

```ruby
Dry::Schema.Params do
  # expands to `required(:id) { str? | int? }`
  required(:id).value([:string, :integer])
end
```

### filled

Use it when a value is expected to be filled. "filled" means that the value is non-nil and, in the case of a `String`, `Hash`, or `Array` value, that the value is not `.empty?`.

```ruby
Dry::Schema.Params do
  # expands to `required(:age) { int? & filled? }`
  required(:age).filled(:integer)
end
```

```ruby
Dry::Schema.Params do
  # expands to `required(:tags) { array? & filled? }`
  required(:tags).filled(:array)
end
```

### maybe

Use it when a value can be nil.

> Notice: do not confuse `maybe` with the `optional` method, which allows **a key to be omitted in the input**, whereas `maybe` is for checking **the value**

```ruby
Dry::Schema.Params do
  # expands to `required(:age) { !nil?.then(int?) }`
  required(:age).maybe(:integer)
end
```

> Caveat: `maybe` doesn't compose with `each`, use the below syntax instead:

```ruby
Dry::Schema.Params do
  required(:list).maybe(array[:string])

  # or

  required(:list).maybe(:array) do
    nil? | each(:string)
  end
end
```

### hash

Use it when a value is expected to be a hash:

```ruby
Dry::Schema.Params do
  # expands to: `required(:tags) { hash? & filled? & schema { required(:name).filled(:string) } } }`
  required(:tags).hash do
    required(:name).filled(:string)
  end
end
```

### schema

This works like `hash` but does not prepend `hash?` predicate. It's a simpler building block for checking nested hashes. Use it when *you* want to provide base checks prior applying rules to values.

```ruby
Dry::Schema.Params do
  # expands to: `required(:tags) { hash? & filled? & schema { required(:name).filled(:string) } } }`
  required(:tags).filled(:hash).schema do
    required(:name).filled(:string)
  end
end
```

### array

Use it to apply predicates to every element in a value that is expected to be an array.

```ruby
Dry::Schema.Params do
  # expands to: `required(:tags) { array? & each { str? } } }`
  required(:tags).array(:str?)
end
```

You can also define an array where elements are hashes:

```ruby
Dry::Schema.Params do
  # expands to: `required(:tags) { array? & each { hash { required(:name).filled(:string) } } } }`
  required(:tags).array(:hash) do
    required(:name).filled(:string)
  end
end
```

### each

This works like `array` but does not prepend `array?` predicate. It's a simpler building block for checking each element of an array. Use it when *you* want to provide base checks prior applying rules to elements.

```ruby
Dry::Schema.Params do
  # expands to: `required(:tags) { array? & each { str? } } }`
  required(:tags).value(:array, min_size?: 2).each(:str?)
end
```

### Learn more

- [Type specs](docs::basics/type-specs)
- [Built-in predicates](docs::basics/built-in-predicates)
- [Working with schemas](docs::basics/working-with-schemas)
