# frozen_string_literal: true

require File.expand_path('lib/dry/schema/version', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'dry-schema'
  spec.version = Dry::Schema::VERSION
  spec.authors = ['Piotr Solnica']
  spec.email = ['piotr.solnica@gmail.com']
  spec.summary = 'Schema coercion and validation'
  spec.homepage = 'https://github.com/dry-rb/dry-schema'
  spec.license = 'MIT'

  spec.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*', 'config/*.yml']
  spec.executables = []
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4'

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.8', '>= 0.8.0'
  spec.add_runtime_dependency 'dry-core', '~> 0.2', '>= 0.2.1'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-initializer', '~> 2.4'
  spec.add_runtime_dependency 'dry-logic', '~> 1.0'
  spec.add_runtime_dependency 'dry-types', '~> 1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
