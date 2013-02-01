require 'spec_helper'

class Skip32Keys < ActiveRecord::Base
  def readonly?
    true
  end
end

describe "system test" do
  it "verifies 100000 sql and ruby values" do
    # (0x0..0xFFFFFFFF).each {|iter|
    #   i = iter
    100000.times do |iter|
      i = (rand * 0xFFFFFFFF).to_i
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
    
      skip32 = Cipher::Skip32.new(key)
      buf = skip32.encrypt(buf.pack("C*")).unpack("C*")
      v_ruby = ((buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + (buf[3]))
      v_ruby = Base32::Crockford::encode(v_ruby)
    
      if (iter % 100) == 0
        print "\r#{"%.3f" % (iter * 100.0 / 100000)}% Done."
      end
    
      if v_ruby != v_sql or v_org != i
        puts "\n\n----------------"
        puts "KEY: #{key}"
        puts "IVAL: #{i}"
        puts "ENC - SQL:#{v_sql} | RUBY:#{v_ruby}"
        puts "DEC - SQL:#{v_org}"
        raise "Testing get error!!!"
      end
    end
  end
end


