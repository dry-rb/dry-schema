# frozen_string_literal: true

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(File.join(__dir__, '..', '.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end

begin
  require 'pry-byebug'
rescue LoadError; end

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join('shared/**/*.rb')].each(&method(:require))
Dir[SPEC_ROOT.join('support/**/*.rb')].each(&method(:require))

require 'dry/schema'
require 'dry/types'

module Types
  include Dry.Types
end

Undefined = Dry::Core::Constants::Undefined

Dry::Schema.load_extensions(:hints)

require 'i18n'
require 'dry/schema/messages/i18n'
require 'dry/schema/message_set'

module MessageSetSupport
  def eql?(other)
    to_h.eql?(other)
  end
end

Dry::Schema::MessageSet.include(MessageSetSupport)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.warnings = true
  config.filter_run_when_matching :focus

  config.include PredicatesIntegration

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  config.before do
    module Test
      def self.remove_constants
        constants.each { |const| remove_const(const) }
        self
      end
    end
  end

  config.after do
    Object.send(:remove_const, Test.remove_constants.name)

    I18n.load_path = [Dry::Schema::DEFAULT_MESSAGES_PATH]
    I18n.locale = :en
    I18n.reload!
  end
end
