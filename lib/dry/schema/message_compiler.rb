# frozen_string_literal: true

require 'dry/schema/constants'
require 'dry/schema/message'
require 'dry/schema/message_set'
require 'dry/schema/message_compiler/visitor_opts'

module Dry
  module Schema
    # Compiles rule results AST into human-readable format
    #
    # @api private
    class MessageCompiler
      attr_reader :messages, :options, :locale, :default_lookup_options

      EMPTY_OPTS = VisitorOpts.new
      LIST_SEPARATOR = ', '.freeze

      # @api private
      def initialize(messages, options = {})
        @messages = messages
        @options = options
        @full = @options.fetch(:full, false)
        @locale = @options[:locale]
        @default_lookup_options = @locale ? { locale: locale } : EMPTY_HASH
      end

      # @api private
      def full?
        @full
      end

      # @api private
      def with(new_options)
        return self if new_options.empty?
        self.class.new(messages, options.merge(new_options))
      end

      # @api private
      def call(ast)
        current_messages = EMPTY_ARRAY.dup
        compiled_messages = ast.map { |node| visit(node, EMPTY_OPTS.dup(current_messages)) }

        MessageSet[compiled_messages, failures: options.fetch(:failures, true)]
      end

      # @api private
      def visit(node, opts = EMPTY_OPTS.dup)
        __send__(:"visit_#{node[0]}", node[1], opts)
      end

      # @api private
      def visit_failure(node, opts)
        rule, other = node
        visit(other, opts.(rule: rule))
      end

      # @api private
      def visit_hint(node, opts)
        nil
      end

      # @api private
      def visit_not(node, opts)
        visit(node, opts.(not: true))
      end

      # @api private
      def visit_and(node, opts)
        left, right = node.map { |n| visit(n, opts) }

        if right
          [left, right]
        else
          left
        end
      end

      # @api private
      def visit_or(node, opts)
        left, right = node.map { |n| visit(n, opts) }

        if [left, right].flatten.map(&:path).uniq.size == 1
          Message::Or.new(left, right, -> k { messages[k, default_lookup_options] })
        elsif right.is_a?(Array)
          right
        else
          [left, right].flatten.max
        end
      end

      # @api private
      def visit_namespace(node, opts)
        ns, rest = node
        self.class.new(messages.namespaced(ns), options).visit(rest, opts)
      end

      # @api private
      def visit_predicate(node, opts)
        base_opts = opts.dup
        predicate, args = node

        *arg_vals, val = args.map(&:last)
        tokens = message_tokens(args)

        input = val != Undefined ? val : nil

        options = base_opts.update(lookup_options(arg_vals: arg_vals, input: input))
        msg_opts = options.update(tokens)

        rule = msg_opts[:rule]
        path = msg_opts[:path]

        template = messages[rule] || messages[predicate, msg_opts]

        unless template
          raise MissingMessageError, "message for #{predicate} was not found"
        end

        text = message_text(rule, template, tokens, options)

        message_type(options)[
          predicate, path, text,
          args: arg_vals,
          input: input,
          rule: rule || msg_opts[:name]
        ]
      end

      # @api private
      def message_type(*)
        Message
      end

      # @api private
      def visit_key(node, opts)
        name, other = node
        visit(other, opts.(path: name))
      end

      # @api private
      def visit_set(node, opts)
        node.map { |el| visit(el, opts) }
      end

      # @api private
      def visit_implication(node, *args)
        _, right = node
        visit(right, *args)
      end

      # @api private
      def visit_xor(node, opts)
        left, right = node
        [visit(left, opts), visit(right, opts)].uniq
      end

      # @api private
      def lookup_options(arg_vals: [], input: nil)
        default_lookup_options.merge(
          arg_type: arg_vals.size == 1 && arg_vals[0].class,
          val_type: input.class
        )
      end

      # @api private
      def message_text(rule, template, tokens, opts)
        text = template[template.data(tokens)]

        if full?
          rule_name = rule ? (messages.rule(rule, opts) || rule) : (opts[:name] || opts[:path].last)
          "#{rule_name} #{text}"
        else
          text
        end
      end

      # @api private
      def message_tokens(args)
        args.each_with_object({}) { |arg, hash|
          case arg[1]
          when Array
            hash[arg[0]] = arg[1].join(LIST_SEPARATOR)
          when Range
            hash["#{arg[0]}_left".to_sym] = arg[1].first
            hash["#{arg[0]}_right".to_sym] = arg[1].last
          else
            hash[arg[0]] = arg[1]
          end
        }
      end
    end
  end
end
