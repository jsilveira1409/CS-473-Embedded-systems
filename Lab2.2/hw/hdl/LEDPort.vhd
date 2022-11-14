library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DaisyPort is
	port(
		clk : in std_logic;
		nReset : in std_logic;
		clk_enable : in std_logic;
		
		-- Internal interface (i.e. Avalon slave).
		address : in std_logic_vector(12 downto 0);
		write : in std_logic;
		writedata : in std_logic_vector(7 downto 0);
		
		
		-- External interface (i.e. conduit).
		LEDPort : out std_logic
	);
end DaisyPort;

architecture comp of DaisyPort is
	signal iRegEnable		: std_logic_vector(7 downto 0);
	signal iRegD1Green	: std_logic_vector(7 downto 0);
	signal iRegD1Red		: std_logic_vector(7 downto 0);
	signal iRegD1Blue		: std_logic_vector(7 downto 0);
	signal iRegD2Green	: std_logic_vector(7 downto 0);
	signal iRegD2Red		: std_logic_vector(7 downto 0);
	signal iRegD2Blue		: std_logic_vector(7 downto 0);
	signal iRegD3Green	: std_logic_vector(7 downto 0);
	signal iRegD3Red		: std_logic_vector(7 downto 0);
	signal iRegD3Blue		: std_logic_vector(7 downto 0);
	signal iRegD4Green	: std_logic_vector(7 downto 0);
	signal iRegD4Red		: std_logic_vector(7 downto 0);
	signal iRegD4Blue		: std_logic_vector(7 downto 0);
	signal Q				   : std_logic_vector(71 downto 0);
	
begin


	-- stock every LED values.
	process(iRegEnable)
	begin
		if iRegEnable(0) = '1'then
			Q(7 downto 0) <= iRegD1Green;
		else
			Q(7 downto 0) <= 'Z'; 
		end if;
		if iRegEnable(1) = '1'then
			Q(15 downto 8) <= iRegD1Red; 
		else
			Q(15 downto 8) <= 'Z'; 
		end if;
		if iRegEnable(2) = '1'then
			Q(23 downto 16) <= iRegD1Blue;
		else
			Q(23 downto 16) <= 'Z'; 	
		end if;
		if iRegEnable(0) = '1'then
			Q(31 downto 24) <= iRegD2Green;
		else
			Q(31 downto 24) <= 'Z'; 
		end if;
		if iRegEnable(1) = '1'then
			Q(39 downto 32) <= iRegD2Red; 
		else
			Q(39 downto 32) <= 'Z'; 
		end if;
		if iRegEnable(2) = '1'then
			Q(47 downto 40) <= iRegD2Blue; 
		else
			Q(47 downto 40) <= 'Z'; 
		end if;
		if iRegEnable(0) = '1'then
			Q(55 downto 48) <= iRegD3Green; 
		else
			Q(55 downto 48) <= 'Z'; 
		end if;
		if iRegEnable(1) = '1'then
			Q(63 downto 56) <= iRegD3Red;
		else
			Q(63 downto 56) <= 'Z'; 	
		end if;
		if iRegEnable(2) = '1'then
			Q(71 downto 64) <= iRegD3Blue;
		else
			Q(71 downto 64) <= 'Z'; 	
		end if;
	end process;
	

	-- Generate PWM value
	process(Q,LEDPort)
	begin
		for i in 0 to 71 loop
			if Q(i) = '1' then
				for i in 0 to 3 loop
					if rising_edge(clk) then
						if clk_enable = '1' then
							LEDPort <= '1';
						end if;
					end if;
				end loop;
				for i in 0 to 7 loop
					if rising_edge(clk) then
						if clk_enable = '1' then
							LEDPort <= '0';
						end if;
					end if;
				end loop;	
			else
				for i in 0 to 6 loop
					if rising_edge(clk) then
						if clk_enable = '1' then
							LEDPort <= '1';
						end if;
					end if;
				end loop;
				for i in 0 to 5 loop
					if rising_edge(clk) then
						if clk_enable = '1' then
							LEDPort <= '0';
						end if;
					end if;
				end loop;		--generate 0 pwm
			end if;
		end loop;
	end process;

	
	-- Avalon slave write to registers.
	process(clk, nReset)
	begin
		if nReset = '0' then
			iRegEnable	<= (others => '0');
			iRegPort 	<= (others => '0');
			iRegD1Green <= (others => '0');
			iRegD1Red	<= (others => '0');
			iRegD1Blue	<= (others => '0');
			iRegD2Green <= (others => '0');
			iRegD2Red	<= (others => '0');
			iRegD2Blue	<= (others => '0');
			iRegD3Green <= (others => '0');
			iRegD3Red	<= (others => '0');
			iRegD3Blue	<= (others => '0');
			iRegD4Green <= (others => '0');
			iRegD4Red	<= (others => '0');
			iRegD4Blue	<= (others => '0');
		elsif rising_edge(clk) then
			if clk_enable = '1' then
				if write = '1' then
					case Address is
						when "0000" => iRegEnable   <= writedata;
						when "0001" => iRegD1Green  <= writedata;
						when "0010" => iRegD1Red	 <= writedata;
						when "0011" => iRegD1Blue	 <= writedata;
						when "0100" => iRegD2Green  <= writedata;
						when "0101" => iRegD2Red	 <= writedata;
						when "0110" => iRegD2Blue	 <= writedata;
						when "0111" => iRegD3Green  <= writedata;
						when "1000" => iRegD3Red	 <= writedata;
						when "1001" => iRegD3Blue	 <= writedata;
						when "1010" => iRegD4Green  <= writedata;
						when "1011" => iRegD4Red	 <= writedata;
						when "1100" => iRegD4Blue	 <= writedata;
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	
end comp;
