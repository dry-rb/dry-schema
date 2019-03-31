require 'benchmark/ips'
require 'hotch'

ENV['HOTCH_VIEWER'] ||= 'open'

require 'dry/schema'

PersonSchema = Dry::Schema.Params do
  required(:name).value(:string)
  required(:age).value(:integer, gteq?: 18)
  required(:email).value(:string)
end

def profile(&block)
  Hotch(filter: 'Dry', &block)
end
