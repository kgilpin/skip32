require "spec_helper"

describe "Sequel Adapter test" do
  before(:all) {
    DB.drop_table :products if DB.table_exists? :products
    DB.create_table :products do
      primary_key :id
      String :name, :null => false
    end
    DB.install_skip32_plsql
    DB.acts_as_skip32 :products, :id
  }
  
  before {
    DB.execute("ALTER SEQUENCE products_id_seq RESTART WITH 1")
  }
  
  it "verifies encrypted pk with ruby result" do
    pk = DB[:products].insert(:name => "Test Product")
    
    DB["SELECT currval('products_id_seq')"].first[:currval].to_i.should == 1
    
    key = DB[:skip32_keys].where("name = 'products'").first[:key]

    # first record will be encrypted with seq 1
    buf = Cipher::Skip32.new(key).encrypt([0,0,0,1].pack("C*")).unpack("C*")
    r_skip32 = ((buf[0] << 24) + (buf[1] << 16) + (buf[2] << 8) + (buf[3]))
    pk.should == Base32::Crockford.encode(r_skip32)
  end
end

