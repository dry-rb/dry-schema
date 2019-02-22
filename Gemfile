source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

group :test do
  gem 'dry-monads', require: false
  gem 'i18n', require: false
  gem 'simplecov', require: false, platform: :mri
  gem 'dry-types', github: 'dry-rb/dry-types', branch: 'rework-schemas'
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
