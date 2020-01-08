---
title: Monads
layout: gem-single
name: dry-schema
---

The monads extension makes `Dry::Schema::Result` objects compatible with dry-monads.

To enable the extension:

```ruby
require 'dry/schema'

Dry::Schema.load_extensions(:monads)
```

After loading the extension, you can leverage monad API:

```ruby
schema = Dry::Schema.Params { required(:name).filled(:string, size?: 2..4) }

schema.call(name: 'Jane').to_monad # => Dry::Monads::Success(#<Dry::Schema::Result{:name=>"Jane"} errors={}>)

schema.call(name: '').to_monad     # => Dry::Monads::Failure(#<Dry::Schema::Result{:name=>""} errors={:name=>["must be filled"]}>)

schema.(name: "")
  .to_monad
  .fmap { |r| puts "passed: #{r.to_h.inspect}" }
  .or   { |r| puts "failed: #{r.errors.to_h.inspect}" }
```

This can be useful when used with dry-monads and [do notation](/gems/dry-monads/1.0/do-notation).

## Using with pattern matching

Ruby 2.7 adds experimental support for pattern matching. Both dry-schema and dry-monads work with it nicely:

```ruby
require 'dry/schema'
require 'dry/monads'

Dry::Schema.load_extensions(:monads)

class Example
  include Dry::Monads[:result]

  Schema = Dry::Schema.Params { required(:name).filled(:string, size?: 2..4) }

  def call(input)
    case schema.(input).to_monad
    in Success(name:)
      "Hello #{name}" # name is captured from result
    in Failure(name:)
      "#{name} is not a valid name"
    end
  end
end

run = Example.new

run.('name' => 'Jane')   # => "Hello Jane"
run.('name' => 'Albert') # => "Albert is not a valid name"
```
