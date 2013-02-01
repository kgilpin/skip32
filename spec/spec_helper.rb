require "rubygems"
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rspec'
require "active_record"
require 'sequel'
require "yaml"
require "integer_obfuscator"
require 'base32/crockford'
require "skip32"

RSpec.configure do |config|
end

spec_dir = File.expand_path('spec', Skip32::root_dir)

begin
  dbconf = YAML.load_file(File.expand_path('database.yml', spec_dir))
rescue
  puts('There is no database.yml');
  exit
end

ActiveRecord::Base.establish_connection ({
  :adapter => "postgresql",
  :host => dbconf['host'],
  :username => dbconf['user'],
  :password => dbconf['password'],
  :database => dbconf['database']})

DB = Sequel.connect(dbconf.merge(adapter: 'postgres'))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
