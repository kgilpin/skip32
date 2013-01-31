skip32 encryption PL/PGSQL


Files

 create_keys_table.sql
   SQL for creating skip32_keys table that contains keys for each table
   This file includes trigger that prevent to update skip32_keys table.
   skip32_keys table must be exist when using skip32 pl/pgsql.
   Execute this sql before using skip32 pl/pgsql.

     $ psql -U user -d database -f create_keys_table.sql

 skip32_sql
   main PL/PGSQL
   includes skip32 engine.

 skip32.rb
   skip32 engine in ruby.

 test.rb
   The test script in ruby, check the result from PL/PGSQL with value
   from ruby engine.

