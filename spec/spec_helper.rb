$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'monocle'
require 'rails'
require 'redis'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

REDIS = Redis.new

RSpec.configure do |config|
  config.after(:each) do
    REDIS.keys('monocle*').each do |key|
      REDIS.del(key)
    end
    sleep(0.5)
  end
end
