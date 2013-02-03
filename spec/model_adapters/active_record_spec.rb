require "spec_helper"

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :products, :force => true do |t|
    t.string :name, :null => false
  end

  install_skip32_plsql
  acts_as_skip32 :products, :id
end

class Product < ActiveRecord::Base
  attr_accessible :name
end

describe "ActiveRecord Adapter test" do
  it "verifies encrypted pk with ruby result" do
    pk = Product.create(:name => "Test Product").id
    key = Skip32Keys.find_by_name('products').key

    # first record will be encrypted with seq 1
    buf = Cipher::Skip32.new(key).encrypt([0,0,0,1].pack("C*")).unpack("C*")
    r_skip32 = ((buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + (buf[3]))
    pk.should == Base32::Crockford.encode(r_skip32)
  end
end

