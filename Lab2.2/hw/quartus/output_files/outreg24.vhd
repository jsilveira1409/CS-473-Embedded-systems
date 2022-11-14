LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY outreg24 IS
	PORT ( clock, resetn : IN STD_LOGIC;
		D : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		byteenable : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		Q : OUT STD_LOGIC_VECTOR(23 DOWNTO 0) );
		
	END outreg24;
	
ARCHITECTURE Behavior OF outreg24 IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		
		IF resetn = '0' THEN
			Q <= "000000000000000000000000";
		ELSE
			IF byteenable(0) = '1'THEN
				Q(7 DOWNTO 0) <= D(7 DOWNTO 0); 
			END IF;
			IF byteenable(1) = '1'THEN
				Q(15 DOWNTO 8) <= D(15 DOWNTO 8); 
			END IF;
			IF byteenable(2) = '1'THEN
				Q(23 DOWNTO 16) <= D(23 DOWNTO 16); 
			END IF;
		END IF;
	END PROCESS;
END Behavior;
