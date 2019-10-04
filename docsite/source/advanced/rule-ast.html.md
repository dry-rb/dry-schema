---
title: Rule AST
layout: gem-single
name: dry-schema
---

The DSL in `dry-schema` is used to create rule objects that are provided by [`dry-logic`](/gems/dry-logic). These rules are built using an AST, which uses simple data structures to represent predicates and how they are composed into complex rules and operations.

The AST can be used to convert it into another representation - for example meta-data that can be used to produce documentation.

### Accessing the AST

To access schema's rule AST use `Schema#to_ast` method:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  optional(:age).filled(:integer, gt?: 18)
end

schema.to_ast
# => [:set,
#  [[:and,
#    [[:predicate, [:key?, [[:name, :email], [:input, Undefined]]]],
#     [:key, [:email, [:and, [[:predicate, [:str?, [[:input, Undefined]]]], [:predicate, [:filled?, [[:input, Undefined]]]]]]]]]],
#   [:implication,
#    [[:predicate, [:key?, [[:name, :age], [:input, Undefined]]]],
#     [:key,
#      [:age,
#       [:and,
#        [[:and, [[:predicate, [:int?, [[:input, Undefined]]]], [:predicate, [:filled?, [[:input, Undefined]]]]]],
#         [:predicate, [:gt?, [[:num, 18], [:input, Undefined]]]]]]]]]]]]
```

### Writing an AST compiler

Even though such a data structure may look scary, it's actually very easy to write a compiler that will turn it into something useful. Let's say you want to generate meta-data about the schema and use it for documentation purposes. To do this, you can write an AST compiler.

Here's a simple example to give you the idea:

```ruby
require 'dry/schema'

class DocCompiler
  def visit(node)
    meth, rest = node
    public_send(:"visit_#{meth}", rest)
  end

  def visit_set(nodes)
    nodes.map { |node| visit(node) }.flatten(1)
  end

  def visit_and(node)
    left, right = node
    [visit(left), visit(right)].compact
  end

  def visit_key(node)
    name, rest = node

    predicates = visit(rest).flatten(1).reduce(:merge)
    validations = predicates.map { |name, args| predicate_description(name, args) }.compact

    { key: name, validations: validations }
  end
  
  def visit_implication(node)
    _, right = node.map(&method(:visit))
    right.merge(optional: true)
  end

  def visit_predicate(node)
    name, args = node

    return if name.equal?(:key?)

    { name => args.map(&:last).reject { |v| v.equal?(Dry::Schema::Undefined) } }
  end

  def predicate_description(name, args)
    case name
    when :str? then "must be a string"
    when :filled? then "must be filled"
    when :int? then "must be an integer"
    when :gt? then "must be greater than #{args[0]}"
    else
      raise NotImplementedError, "#{name} not supported yet"
    end
  end
end
```

With such a compiler we can now turn schema's rule AST into a list of hashes that describe keys and their validations:

``` ruby
compiler = DocCompiler.new

compiler.visit(schema.to_ast)
# [
#   {:key=>:email, :validations=>["must be filled", "must be a string"]},
#   {:key=>:age, :validations=>["must be filled", "must be an integer", "must be greater than 18"], :optional=>true}
# ]
```
