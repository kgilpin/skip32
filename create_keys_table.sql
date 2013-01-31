-- ----------------------------
-- Table structure for "public"."skip32_keys"
-- ----------------------------
DROP TABLE "public"."skip32_keys";
CREATE TABLE "public"."skip32_keys" (
	"name" varchar(64) NOT NULL,
	"key" varchar(32) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."skip32_keys" ADD PRIMARY KEY ("name");

-- ----------------------
-- Create trigger to prevent managing keys tabe rows.
-- ----------------------
CREATE or REPLACE FUNCTION prevent_update_keys() RETURNS trigger AS $prevent_update_keys$
	BEGIN
		RAISE EXCEPTION 'SKIP32: Access denied';
	END;
$prevent_update_keys$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_update_keys BEFORE DELETE OR UPDATE ON skip32_keys
	FOR EACH ROW EXECUTE PROCEDURE prevent_update_keys();

