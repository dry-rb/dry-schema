source 'https://rubygems.org'

gemspec

gem 'dry-logic', git: 'https://github.com/dry-rb/dry-logic.git', branch: 'master'
gem 'dry-types', git: 'https://github.com/dry-rb/dry-types.git', branch: 'master'

group :test do
  gem 'i18n', require: false
  platform :mri do
    gem 'simplecov', require: false
  end
  gem 'dry-monads', require: false
  gem 'dry-struct', require: false
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'pry'
  gem 'redcarpet'
end

group :benchmarks do
  gem 'hotch', platform: :mri
  gem 'activemodel', '~> 5.0'
  gem 'actionpack', '~> 5.0'
  gem 'benchmark-ips'
  gem 'virtus'
end
