---
title: Monads
layout: gem-single
name: dry-schema
---

The monads extension makes `Dry::Schema::Result` objects compatible with `dry-monads`.

To enable the extension:

```ruby
require 'dry/schema'

Dry::Schema.load_extensions(:monads)
```

After loading the extension, you can leverage monad API:

```ruby
schema = Dry::Schema.Params { required(:name).filled(:str?, size?: 2..4) }

schema.call(name: 'Jane').to_monad # => Dry::Monads::Success(#<Dry::Schema::Result{:name=>"Jane"} errors={}>)

schema.call(name: '').to_monad     # => Dry::Monads::Failure(#<Dry::Schema::Result{:name=>""} errors={:name=>["must be filled"]}>)

schema.(name: "")
  .to_monad
  .fmap { |r| puts "passed: #{r.to_h.inspect}" }
  .or   { |r| puts "failed: #{r.errors.to_h.inspect}" }
```

This can be useful when used with `dry-monads` and the [`do` notation](/gems/dry-monads/do-notation/).
