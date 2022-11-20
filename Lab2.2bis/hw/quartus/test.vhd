LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PWMPort IS
	PORT (
		clk : IN STD_LOGIC;
		nReset : IN STD_LOGIC;
		-- Internal interface (i.e. Avalon slave).
		address : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		write : IN STD_LOGIC;
		read : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		readdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

		-- External interface (i.e. conduit).
		PwmOut : OUT STD_LOGIC
	);
END PWMPort;

ARCHITECTURE comp OF PWMPort IS
	SIGNAL iRegCycles : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL iRegActiveCycles : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL iRegPolarity : STD_LOGIC;
	SIGNAL iRegClockDivider : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0640";

	SIGNAL enable : STD_LOGIC;
	SIGNAL clock_divider_counter : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL pwm_counter : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
	PROCESS (clk, nReset)
		VARIABLE e : STD_LOGIC;
	BEGIN
		IF nReset = '0' THEN
			clock_divider_counter <= "00000000000";
		ELSIF rising_edge(clk) THEN
			e := '0';

			IF to_integer(unsigned(clock_divider_counter)) = to_integer(unsigned(iRegClockDivider)) THEN
				e := '1';
				clock_divider_counter <= "00000000000";
			ELSE
				clock_divider_counter <= STD_LOGIC_VECTOR(unsigned(clock_divider_counter) + 1);
			END IF;
			enable <= e;
		END IF;

	END PROCESS;

	-- Avalon slave write to registers.
	PROCESS (clk, nReset)
	BEGIN
		IF nReset = '0' THEN
			iRegCycles <= (OTHERS => '0');
			iRegActiveCycles <= (OTHERS => '0');
			iRegPolarity <= '0';
		ELSIF rising_edge(clk) THEN
			IF write = '1' THEN
				CASE address IS
					WHEN "00" => iRegCycles <= writedata;
					WHEN "01" => iRegActiveCycles <= writedata;
					WHEN "10" => iRegPolarity <= writedata(0); 
					WHEN "11" => iRegClockDivider <= writedata;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS;

	-- Avalon slave read from registers.
	PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			readdata <= (OTHERS => '0');
			IF read = '1' THEN
				CASE address IS
					WHEN "00" => readdata <= iRegCycles;
					WHEN "01" => readdata <= iRegActiveCycles;
					WHEN "10" => readdata <= "000000000000000" & iRegPolarity; 
					WHEN "11" => readdata <= iRegClockDivider;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (clk)
		VARIABLE i_counter : STD_LOGIC_VECTOR(15 DOWNTO 0);
	BEGIN
		IF rising_edge(clk) THEN
			IF enable = '1' THEN
				i_counter := pwm_counter;
				IF unsigned(i_counter) < unsigned(iRegActiveCycles) THEN
					PwmOut <= iRegPolarity;
					i_counter := STD_LOGIC_VECTOR(unsigned(i_counter) + 1);
				ELSIF unsigned(i_counter) < unsigned(iRegCycles) THEN
					PwmOut <= NOT(iRegPolarity);
					i_counter := STD_LOGIC_VECTOR(unsigned(i_counter) + 1);
				ELSE
					i_counter := "0000000000000000";
				END IF;
				pwm_counter <= i_counter;

			END IF;
		END IF;
	END PROCESS;

END comp;
