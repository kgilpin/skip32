require "rubygems"
require "active_record"

require File.expand_path('../skip32.rb', __FILE__)

ActiveRecord::Base.establish_connection ({
  :adapter => "postgresql",
  :host => "localhost",
  :username => "test",
  :password => "",
  :database => "skip32"})

class Skip32Keys < ActiveRecord::Base
  attr_accessible :name, :key
end

(0x0..0xFFFFFFFF).each {|i|
  x = ActiveRecord::Base.connection.execute("select skip32('product', #{i});")
  v_sql = x.first['skip32'].to_i
  key = Skip32Keys.find_by_name('product').key

  buf = []
  buf[0] = (i >> 24) & 0xFF
  buf[1] = (i >> 16) & 0xFF
  buf[2] = (i >> 8) & 0xFF
  buf[3] = i & 0xFF

  skip32(key.unpack('C*'), buf, true)
  v_ruby = ((buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + (buf[3]))

  if (i % 0x100) == 0
    print "\r#{"%.3f" % (i * 100.0 / 0xFFFFFF)}% Done."
  end

  if v_ruby != v_sql
    puts "KEY: #{key}"
    puts "IVAL: #{i}"
    puts "ENC - SQL:#{v_sql} | RUBY:#{v_ruby}"
    raise "Testing get error!!!"
  end
}


