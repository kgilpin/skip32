require "skip32/version"
require "skip32/sequel"
require "skip32/activerecord"

module Skip32
  def self.plsql
      sql = File.read(File.expand_path('sql/create_keys_table.sql', Skip32::root_dir))
      sql = sql + File.read(File.expand_path('sql/crockford.sql', Skip32::root_dir))
      sql = sql + File.read(File.expand_path('sql/skip32.sql', Skip32::root_dir))
  end

  def self.root_dir
    File.expand_path('../', File.dirname(__FILE__))
  end
end
