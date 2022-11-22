library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DaisyPort is
	port(
		clk			: in std_logic;
		nReset		: in std_logic;
		
		-- internal interface (avalon slave)
		address		: in std_logic_vector(3 downto 0);
		write			: in std_logic;
		writedata	: in std_logic_vector(31 downto 0);
	
		-- external interface (conduit)
		LEDPort 		: out std_logic;
		TrueOutput	:	out std_logic;
		countOutput : out integer
	);
end DaisyPort;


architecture behaviour of DaisyPort is 
	signal iRegD1			: std_logic_vector(31 downto 0);
	signal iRegD2			: std_logic_vector(31 downto 0);
	signal iRegD3			: std_logic_vector(31 downto 0);
	signal iRegD4			: std_logic_vector(31 downto 0);
	signal output_val		: std_logic_vector(127 downto 0);
	signal output			: std_logic;
	signal next_send 		: std_logic;
	signal reset_diode		: std_logic;
		
begin
	
	
	-- Avalon slave write to registers.
	process(clk, nReset, Address)
		begin
			if nReset = '0' then
				iRegD1	<= (others => '0');
				iRegD2	<= (others => '0');
				iRegD3	<= (others => '0');
				iRegD4	<= (others => '0');
			elsif rising_edge(clk) then
				if write = '1' then
					case Address is
						when "0001" => iRegD1(23 downto 0)		 <= writedata(23 downto 0);
						when "0010" => iRegD2(23 downto 0)		 <= writedata(23 downto 0);
						when "0011" => iRegD3(23 downto 0)		 <= writedata(23 downto 0);
						when "0100" => iRegD4(23 downto 0)		 <= writedata(23 downto 0);
						when others => null;
					end case;
				end if;
			end if;	
	end process;
	
				
-- set the send variable depending on 
process(clk, nReset)

	variable index : integer := 0;
	variable count : integer := 1;

	begin
		if nReset = '0' then
			TrueOutput <= '1';
			index := 0;
			next_send <= '1';
			output <= '0';
			LEDPort <= '0';
			countOutput <= 0;
			reset_diode <= '0';
		elsif rising_edge(clk) then
			if write = '0' then
				if next_send = '1' then
					output <= output_val(index);
					TrueOutput <= output_val(index);	
					index := index + 1;
					countOutput <= index;
					if index >= 96 then
						index := 0;
						reset_diode <= '1';
					end if;
					next_send <= '0';
				elsif next_send = '0' then
					if reset_diode = '0' then
						if output = '1' then

							if count <= 20 then
								LEDPort <= '1';
							elsif count > 20 and count <= 60 then
								LEDPort <= '0';
							else 
								count := 0;
								next_send <= '1';
							end if;
				
						elsif output = '0' then
		
							if count <= 35 then
								LEDPort <= '1';
							elsif count > 35 and count <= 65 then
								LEDPort <= '0';
							else 
								count := 0;
								next_send <= '1';
							end if;

						end if;				
						count := count + 1;
					elsif reset_diode = '1' then
						if count <= 2500 then
							LEDPort <= '0';
						else 
							count := 0;
							reset_diode <= '0';
							next_send <= '1';
						end if;
						count := count + 1;
					end if;
				end if;
			end if;
		end if;
end process;
	


process (clk, nReset)
begin
		if nReset = '0' then
			output_val <= (others => '0');
		elsif rising_edge(clk) then
			--if write = '1' then
				output_val(23 downto 0) <= iRegD1(23 downto 0);
				output_val(47 downto 24) <= iRegD2(23 downto 0);
				output_val(71 downto 48) <= iRegD3(23 downto 0);
				output_val(95 downto 72) <= iRegD4(23 downto 0);
			--end if;
		end if;

end process;
end behaviour;