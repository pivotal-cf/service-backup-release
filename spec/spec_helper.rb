require 'rspec'
require 'rspec/its'

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.color = true
  c.full_backtrace = true
  c.order = 'random'
end
