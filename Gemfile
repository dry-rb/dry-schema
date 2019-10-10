# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name| "https://github.com/#{repo_name}" end

gemspec

gem 'dry-logic', github: 'dry-rb/dry-logic', branch: 'master' if ENV['DRY_LOGIC_FROM_MASTER'].eql?('true')
gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master' if ENV['DRY_TYPES_FROM_MASTER'].eql?('true')

gem 'ossy', github: 'solnic/ossy', branch: 'master'

group :test do
  gem 'dry-monads', require: false
  gem 'i18n', require: false
  gem 'simplecov', require: false, platform: :mri
  gem 'transproc'
end

group :tools do
  gem 'pry'
  gem 'pry-byebug', platform: :mri
  gem 'redcarpet', platform: :mri
end

group :benchmarks do
  gem 'actionpack', '~> 5.0'
  gem 'activemodel', '~> 5.0'
  gem 'benchmark-ips'
  gem 'hotch', platform: :mri
  gem 'virtus'
end
