$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rspec"
require "monocle"

require "rails"
require "active_record"
require "database_cleaner"
require "shoulda-matchers"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => File.expand_path("spec/db/monocle.sqlite3"))

ActiveRecord::Migrator.migrate(File.expand_path("spec/db/migrate"))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def create_view(options = {})
  values = {
    :viewable_type => "Viewable",
    :viewable_id => 1,
    :viewed_on_start_date => Time.now - 10.days,
    :views => 10 }.merge(options)

  %w( Daily Weekly Monthly Yearly Overall ).each do |time_span|
    klass = "Monocle::#{time_span}View".constantize
    klass.create(values)
  end
end

RSpec.configure do |config|
  config.mock_with :mocha 

  config.after(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
