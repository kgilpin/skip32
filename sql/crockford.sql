--
-- crockford helper function
-- reversing bits.
--
CREATE or REPLACE FUNCTION kreverse(ival BIT, start_first BOOLEAN default TRUE) RETURNS BIT AS $BODY$
DECLARE
	ret varbit;
	i integer;
	first BOOLEAN;
BEGIN
	first = start_first;
	ret = B'';
	i = 1;
	while (i <= length(ival)) LOOP
		IF (substring(ival, i, 1) = '1') THEN first = FALSE; END IF;
		IF first = FALSE THEN
			ret = substring(ival, i, 1) || ret;
		END IF;
		i = i + 1;
	END LOOP;
	IF length(ret) = 0 THEN ret = B'0'; END IF;
	return ret;
END; $BODY$ LANGUAGE plpgsql IMMUTABLE;

--
-- Encrypt function
--  returns encrypted string.
--  parameters
--     ival: int to be encrpted
--     ln: length of string to be returned.
--         default null, ignore
--         right adjust with '0'.
--         ex) crockford(21) will return 'N'
--             crockford(21, 4) will return '000N'
--
CREATE OR REPLACE FUNCTION crockford(ival BIGINT, ln INTEGER DEFAULT NULL) RETURNS TEXT AS $BODY$
DECLARE
  ENC_CHARS TEXT;
	rb VARBIT;
	i INTEGER;
	m varbit;
	ret TEXT;
BEGIN
	ret  = '';
	ENC_CHARS = '0123456789ABCDEFGHJKMNPQRSTVWXYZ?';
	rb = kreverse(ival::BIT(64));

	i = 1;
	while (i <= length(rb))	LOOP
		m = SUBSTRING(rb, i, 5);
		ret = SUBSTRING(ENC_CHARS, kreverse(m, false)::INTEGER+1, 1) || ret;
		i = i+5;
	END LOOP;

	IF ln IS NOT NULL and ln > length(ret) THEN
		ret = repeat('0', ln - length(ret)) || ret;
	END IF;

	return ret;
END $BODY$ LANGUAGE 'plpgsql';


--
-- decypt function
--
CREATE OR REPLACE FUNCTION crockford_dec(str TEXT) RETURNS BIGINT AS $BODY$
DECLARE
	ret BIGINT;
	ENC_CHARS TEXT;
	i INTEGER;
	pos INTEGER;
BEGIN
	ret = 0;
	ENC_CHARS = '0123456789ABCDEFGHJKMNPQRSTVWXYZ?';
	i = 1;
	WHILE (i <= length(str)) LOOP
		pos = strpos(ENC_CHARS, SUBSTRING(str, i, 1)) - 1;
		IF (pos < 0) THEN RAISE EXCEPTION 'Invalid source'; END IF;
		ret = (ret << 5) + pos;
		i = i + 1;
	END LOOP;

	return ret;
END $BODY$ LANGUAGE 'plpgsql';

