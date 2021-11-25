---
title: Predicate logic
layout: gem-single
name: dry-schema
---

Schema DSL allows you to define validation rules using predicate logic. All common logic operators are supported and you can use them to **compose rules**. This simple technique is very powerful as it allows you to compose validations in such a way that invalid state will not crash one of your rules. Validation is a process that always depends on specific conditions, in that sense, `dry-schema` schemas have rules that are always conditional, they are executed only if defined conditions are met.

This document explains how rule composition works in terms of predicate logic.

### Conjunction (and)

```ruby
Dry::Schema.Params do
  required(:age) { int? & gt?(18) }
end
```

`:age` rule is successful when both predicates return `true`.

### Disjunction (or)

```ruby
Dry::Schema.Params do
  required(:age) { nil? | int? }
end
```

`:age` rule is successful when either of the predicates, or both return `true`.

### Implication (then)

```ruby
Dry::Schema.Params do
  required(:age) { filled? > int? }
end
```

`:age` rule is successful when `filled?` returns `false`, or when both predicates return `true`.

> [Optional keys](docs::optional-keys-and-values) are defined using `implication`, that's why a missing key will not cause its rules to be applied and the whole key rule will be successful

### Exclusive Disjunction (xor)

```ruby
Dry::Schema.Params do
  required(:status).value(:integer) { even? ^ lt?(0) }
end
```

`:status` is valid if it's either an even integer, or it's value is less than `0`.

### Operator Aliases

Logic operators are actually aliases, use full method names at your own convenience:

- `and` => `&`
- `or` => `|`
- `then` => `>`
- `xor` => `^`
