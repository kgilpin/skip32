#require 'active_record'

module Base
    def kkk
	puts 'kkkkkk'
    end
    
    class KMS < Object
	def self.jj
	    kkk
	end
    end
end

module KMS
    
    module MigrationClassMethods
	def kk
	    puts 'l,s'
	end
    end
    
    Base::KMS.send('extend', KMS::MigrationClassMethods)
end

require 'rubygems'
require 'sequel'

DB = Sequel.sqlite # memory database

DB.create_table :items do
  primary_key :id
  String :name
  Float :price
end

DB.alter_table :items do
  puts self.class
end
#Base::KMS.jj
