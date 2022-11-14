LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY daisy IS
	PORT ( 
		clock, resetn 	: IN STD_LOGIC;
		write				: IN STD_LOGIC;
		read				: IN STD_LOGIC;
		--send				: IN STD_LOGIC;
		writedata		: IN STD_LOGIC_VECTOR(71 DOWNTO 0);
		readdata			: OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
		chipselect		: IN STD_LOGIC;
		byteenable 		: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		Q 					: OUT STD_LOGIC_VECTOR(71 DOWNTO 0) );

		
	END daisy;
	
ARCHITECTURE Behavior OF daisy IS
BEGIN
	PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		
		IF resetn = '0' THEN
			Q <= "000000000000000000000000000000000000000000000000000000000000000000000000";
		ELSE
			IF byteenable(0) = '1'THEN
				Q(7 DOWNTO 0) <= writedata(7 DOWNTO 0); 
			END IF;
			IF byteenable(1) = '1'THEN
				Q(15 DOWNTO 8) <= writedata(15 DOWNTO 8); 
			END IF;
			IF byteenable(2) = '1'THEN
				Q(23 DOWNTO 16) <= writedata(23 DOWNTO 16); 
			END IF;
			IF byteenable(0) = '1'THEN
				Q(31 DOWNTO 24) <= writedata(31 DOWNTO 24);
			END IF;
			IF byteenable(1) = '1'THEN
				Q(39 DOWNTO 32) <= writedata(39 DOWNTO 32); 
			END IF;
			IF byteenable(2) = '1'THEN
				Q(47 DOWNTO 40) <= writedata(47 DOWNTO 40); 
			END IF;
			IF byteenable(0) = '1'THEN
				Q(55 DOWNTO 48) <= writedata(55 DOWNTO 48); 
			END IF;
			IF byteenable(1) = '1'THEN
				Q(63 DOWNTO 56) <= writedata(63 DOWNTO 56); 
			END IF;
			IF byteenable(2) = '1'THEN
				Q(71 DOWNTO 64) <= writedata(71 DOWNTO 64); 
			END IF;
		
		END IF;
	END PROCESS;
END Behavior;
