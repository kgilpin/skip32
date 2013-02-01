# 
# ActiveRecord migration class extention
#

module Skip32
  module SequelClassMethods

    def install_skip32_plsql
      run(Skip32::plsql);
    end

    def acts_as_skip32(table, column)
      alter_table table.to_sym do
        set_column_type column.to_sym, :text
      end

      run <<-SQL
        ALTER TABLE "products"
          ALTER COLUMN "#{column.to_s}"
          set DEFAULT crockford(skip32('#{table.to_s}'::text, nextval('#{table.to_s}_id_seq'::regclass)))
      SQL
    end
  end

  Sequel::Database.send(:include, SequelClassMethods)
end

