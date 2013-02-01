-- key finder
CREATE or REPLACE FUNCTION find_or_create_key(key_id TEXT) RETURNS TEXT AS $$
	DECLARE
		k TEXT;
	BEGIN
		SELECT key INTO k FROM skip32_keys WHERE name = key_id;
		IF k is NULL THEN
			INSERT INTO skip32_keys VALUES(key_id) RETURNING key INTO k;
		END IF;
		RETURN k;
	END;
$$ LANGUAGE plpgsql;

-- skip32 helper method
CREATE or REPLACE FUNCTION _g(key TEXT, k INTEGER, w BIGINT) RETURNS INTEGER AS $$
	DECLARE
		ftable INTEGER[];
		g1 INTEGER;
		g2 INTEGER;
		g3 INTEGER;
		g4 INTEGER;
		g5 INTEGER;
		g6 INTEGER;
	BEGIN
		ftable = ARRAY[163, 215, 9, 131, 248, 72, 246, 244, 179, 33, 21, 120, 153, 177, 175, 249, 231, 45, 77, 138, 206, 76, 202, 46, 82, 149, 217, 30, 78, 56, 68, 40, 10, 223, 2, 160, 23, 241, 96, 104, 18, 183, 122, 195, 233, 250, 61, 83, 150, 132, 107, 186, 242, 99, 154, 25, 124, 174, 229, 245, 247, 22, 106, 162, 57, 182, 123, 15, 193, 147, 129, 27, 238, 180, 26, 234, 208, 145, 47, 184, 85, 185, 218, 133, 63, 65, 191, 224, 90, 88, 128, 95, 102, 11, 216, 144, 53, 213, 192, 167, 51, 6, 101, 105, 69, 0, 148, 86, 109, 152, 155, 118, 151, 252, 178, 194, 176, 254, 219, 32, 225, 235, 214, 228, 221, 71, 74, 29, 66, 237, 158, 110, 73, 60, 205, 67, 39, 210, 7, 212, 222, 199, 103, 24, 137, 203, 48, 31, 141, 198, 143, 170, 200, 116, 220, 201, 93, 92, 49, 164, 112, 136, 97, 44, 159, 13, 43, 135, 80, 130, 84, 100, 38, 125, 3, 64, 52, 75, 28, 115, 209, 196, 253, 59, 204, 251, 127, 171, 230, 62, 91, 165, 173, 4, 35, 156, 20, 81, 34, 240, 41, 121, 113, 126, 255, 140, 14, 226, 12, 239, 188, 114, 117, 111, 55, 161, 236, 211, 142, 98, 139, 134, 16, 232, 8, 119, 17, 190, 146, 79, 36, 197, 50, 54, 157, 207, 243, 166, 187, 172, 94, 108, 169, 19, 87, 37, 181, 227, 189, 168, 58, 1, 5, 89, 42, 70];

		g1 = (w >> 8) & 255;
		g2 = w & 255;

		g3 = ftable[(g2 # ascii(substring(key, (4*k)%10+1, 1))) + 1] # g1;
		g4 = ftable[(g3 # ascii(substring(key, (4*k+1)%10+1, 1))) + 1] # g2;
		g5 = ftable[(g4 # ascii(substring(key, (4*k+2)%10+1, 1))) + 1] # g3;
		g6 = ftable[(g5 # ascii(substring(key, (4*k+3)%10+1, 1))) + 1] # g4;

		RETURN (g5 << 8) + g6;
	END;
$$ LANGUAGE plpgsql;

--###################################################################
-- skip32 engine
--  param:
--    key_id: id, string format
--    ival: plain input to be encrypted
--    encrypt: indicate enc/dec direct
--      true: encrypt (default)
--      false: decrypt
--###################################################################
CREATE or REPLACE FUNCTION skip32(key_id TEXT, ival BIGINT, encrypt BOOLEAN default true) RETURNS BIGINT AS $$
	DECLARE
		key TEXT;
		buf INTEGER[];
		kstep INTEGER;
		k INTEGER;
		wl BIGINT;
		wr BIGINT;
		i INTEGER;
	BEGIN
		key = find_or_create_key(key_id);
		-- pack into words
		wr = ival & x'FFFF'::INTEGER;
		wl = (ival >> 16) & x'FFFF'::INTEGER;

		-- sort out direction
		IF encrypt then
			kstep = 1; k = 0;
		ELSE
			kstep = -1; k = 23;
		END IF;

		-- 24 feistel rounds, doubled up
		i = 1;
		LOOP
			wr = wr # _g(key, k, wl) # k;
			k = k + kstep;
			wl = wl # _g(key, k, wr) # k;
			k = k + kstep;
			exit when i >= 12;
			i = i + 1;
		END loop;

		RETURN wl + (wr << 16);
	END;
$$ LANGUAGE plpgsql;

-- usage
-- select skip32('product', 3);


