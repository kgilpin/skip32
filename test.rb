require "rubygems"
require "active_record"
require "yaml"

require File.expand_path('../skip32.rb', __FILE__)
require File.expand_path('../crockford.rb', __FILE__)

begin
  dbconf = YAML.load_file('database.yml')
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

class Skip32Keys < ActiveRecord::Base
  def readonly?
    true
  end
end

(0x0..0xFFFFFFFF).each {|i|
  x = ActiveRecord::Base.connection.execute("select crockford(skip32('product', #{i})) as val;")
  v_sql = x.first['val']
  x = ActiveRecord::Base.connection.execute("select skip32('product', crockford_dec('#{v_sql}'), false) as val;")
  v_org = x.first['val'].to_i
  key = Skip32Keys.find_by_name('product').key
  

  buf = []
  buf[0] = (i >> 24) & 0xFF
  buf[1] = (i >> 16) & 0xFF
  buf[2] = (i >> 8) & 0xFF
  buf[3] = i & 0xFF

  skip32(key.unpack('C*'), buf, true)
  v_ruby = ((buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + (buf[3]))
  v_ruby = Base32::Crockford::encode(v_ruby)

  if (i % 0x100) == 0
    print "\r#{"%.3f" % (i * 100.0 / 0xFFFFFFFF)}% Done."
  end

  if v_ruby != v_sql or v_org != i
    puts "\n\n----------------"
    puts "KEY: #{key}"
    puts "IVAL: #{i}"
    puts "ENC - SQL:#{v_sql} | RUBY:#{v_ruby}"
    puts "DEC - SQL:#{v_org}"
    raise "Testing get error!!!"
  end
}


