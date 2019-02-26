source 'https://rubygems.org'

gemspec

group :test do
  gem 'dry-monads', require: false
  gem 'i18n', require: false
  gem 'simplecov', require: false, platform: :mri
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
