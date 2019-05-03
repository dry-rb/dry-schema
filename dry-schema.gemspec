# frozen_string_literal: true

require File.expand_path('lib/dry/schema/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'dry-schema'
  spec.version = Dry::Schema::VERSION
  spec.authors = ['Piotr Solnica']
  spec.email = ['piotr.solnica@gmail.com']
  spec.summary = 'Coercion and validation for data structures'
  spec.description = <<~STR
    dry-schema provides a DSL for defining schemas with keys and rules that should be applied to
    values. It supports coercion, input sanitization, custom types and localized error messages
    (with or without I18n gem). It's also used as the schema engine in dry-validation.
  STR
  spec.homepage = 'https://github.com/dry-rb/dry-schema'
  spec.license = 'MIT'

  spec.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*', 'config/*.yml']
  spec.executables = []
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4'

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.8', '>= 0.8.0'
  spec.add_runtime_dependency 'dry-core', '~> 0.4'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-initializer', '~> 3.0'
  spec.add_runtime_dependency 'dry-logic', '~> 1.0'
  spec.add_runtime_dependency 'dry-types', '~> 1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
