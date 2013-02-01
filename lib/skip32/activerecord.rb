# 
# ActiveRecord migration class extention
#

class Skip32Keys < ActiveRecord::Base
  def readonly?
    true
  end
end

module Skip32
  module MigrationClassMethods

    def install_skip32_plsql
      execute(Skip32::plsql);
    end

    def acts_as_skip32(table, column)
      change_column table.to_sym, column.to_sym, :text
      execute <<-SQL
        ALTER TABLE "products"
          ALTER COLUMN "#{column.to_s}"
          set DEFAULT crockford(skip32('#{table.to_s}'::text, nextval('#{table.to_s}_id_seq'::regclass)))
      SQL
    end
  end

  ActiveRecord::Migration.send(:include, MigrationClassMethods)
end

