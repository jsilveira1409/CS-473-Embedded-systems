library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DaisyPort2 is
	port(
		clk			: in std_logic;
		nReset		: in std_logic;
		
		-- internal interface (avalon slave)
		address		: in std_logic_vector(3 downto 0);
		write			: in std_logic;
		writedata	: in std_logic_vector(31 downto 0);
	
		-- external interface (conduit)
		LEDPort 		: out std_logic;
		testPort		: out std_logic
	);
end DaisyPort2;


architecture behaviour of DaisyPort2 is 
	signal iRegD1			: std_logic_vector(31 downto 0);
	signal iRegD2			: std_logic_vector(31 downto 0);
	signal iRegD3			: std_logic_vector(31 downto 0);
	signal iRegD4			: std_logic_vector(31 downto 0);
	signal output_val		: std_logic_vector(95 downto 0);
	signal enable			: std_logic;
	signal active_cycles		: integer;
	signal cycles			: integer;
	signal counter 			: integer;
		
begin
	
	
	-- Avalon slave write to registers.
	process(clk, nReset, Address)
		begin
			if nReset = '0' then
				iRegD1	<= (others => '0');
				iRegD2	<= (others => '0');
				iRegD3	<= (others => '0');
				iRegD4	<= (others => '0');
				output_val <= (others => '0');
			elsif rising_edge(clk) then
				if write = '1' then
					case Address is
						when "0001" => iRegD1(23 downto 0)		 <= writedata(23 downto 0);
						when "0010" => iRegD2(23 downto 0)		 <= writedata(23 downto 0);
						when "0011" => iRegD3(23 downto 0)		 <= writedata(23 downto 0);
						when "0100" => iRegD4(23 downto 0)		 <= writedata(23 downto 0);
						when others => null;
					end case;
						output_val(23 downto 0) <= iRegD1(23 downto 0);
						output_val(47 downto 24) <= iRegD2(23 downto 0);
						output_val(71 downto 48) <= iRegD3(23 downto 0);
						output_val(95 downto 72) <= iRegD4(23 downto 0);
				end if;
			end if;	
	end process;


process (clk, enable)
		variable index : integer := 0;
		variable e : std_logic;

		
	begin
		if nReset = '0' then
			active_cycles <= 0;
			cycles <= 0;
			enable <= '0';
			testPort <= '0';
			LEDPort <= '0';
		elsif rising_edge(clk) then
			e := '0';
			if enable = '0' then
				if output_val(index) = '0' then
					active_cycles <= 18;
					cycles <= 58;
					e := '1';
				elsif output_val(index) = '1' then
					active_cycles <= 35;
					cycles <= 65;
					e := '1';
				end if;
				enable <= e;
				index := index + 1;
			end if;

		end if;
	end process;

				
-- set the send variable depending on 
process(clk)

	variable internal_counter : integer:=0 ;
	
	begin	
		if rising_edge(clk) then
		
			if enable = '1' then
				internal_counter := counter;
				if internal_counter < active_cycles then
					LEDPort <= '1';
					internal_counter := internal_counter + 1;
				elsif internal_counter < cycles then
					LEDPort <= '0';
					internal_counter := internal_counter + 1;
				else
					internal_counter := 0;
				end if;
				
				counter <= internal_counter;
				testPort <= internal_counter;

			end if;
		end if;
end process;
	


end behaviour;