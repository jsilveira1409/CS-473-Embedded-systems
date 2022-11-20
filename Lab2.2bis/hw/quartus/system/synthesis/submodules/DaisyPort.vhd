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
		writedata	: in std_logic_vector(23 downto 0);
	
		-- external interface (conduit)
		LEDPort 		: out std_logic
	);
end DaisyPort;


architecture behaviour of DaisyPort is 
	type StateType is (Idle,LED1,LED2,LED3,LED4);			--define states
	signal iRegEnable		: std_logic_vector(23 downto 0);
	signal iRegD1			: std_logic_vector(23 downto 0);
	signal iRegD2			: std_logic_vector(23 downto 0);
	signal iRegD3			: std_logic_vector(23 downto 0);
	signal iRegD4			: std_logic_vector(23 downto 0);
	signal send				: std_logic;
	signal output_val		: std_logic_vector(23 downto 0);
	signal output			: std_logic;
	signal clk_enable 	: std_logic;
	signal clk_div_counter : std_logic_vector(10 downto 0);
	
	constant CounterMaxValue 	: integer := 5;
		
begin

	-- clock divider
	process (clk, nReset)
		variable e : std_logic;
	begin
		if nReset = '0' then
			clk_div_counter <= (others => '0' );
		elsif rising_edge(clk) then
			e := '0';
			if to_integer(unsigned(clk_div_counter)) = CounterMaxValue then
				e := '1';
				clk_div_counter <= (others => '0' );
			else
				clk_div_counter <= std_logic_vector(unsigned(clk_div_counter) + 1);
			end if;
			clk_enable <= e;
		end if;
	end process;
	
	-- Avalon slave write to registers.
	process(clk, nReset)
	begin
		if nReset = '0' then
			iRegEnable	<= (others => '0');
			iRegD1	<= (others => '0');
			iRegD2	<= (others => '0');
			iRegD3	<= (others => '0');
			iRegD4	<= (others => '0');
		elsif rising_edge(clk) then
			if clk_enable = '1' then
				if write = '1' then
					case Address is
						when "0000" => iRegEnable   <= writedata;
						when "0001" => iRegD1		 <= writedata;
						when "0010" => iRegD2		 <= writedata;
						when "0011" => iRegD3		 <= writedata;
						when "0100" => iRegD4		 <= writedata;
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	--send 1 or 0 depending on send
	process(send, clk_enable, nReset)

	variable count : integer := 0;
	
	begin
		if nReset = '1' then
			LEDPort <= '0';
		elsif rising_edge(clk_enable) then
			if send = '1' then

				if count <= 6 then
					LEDPort <= '1';
				elsif count > 6 and count <= 12 then
					LEDPort <= '0';
				else 
					count := 0;
				end if;
			
			elsif send = '0' then
	
				if count <= 3 then
					LEDPort <= '1';
				elsif count > 3 and count <= 11 then
					LEDPort <= '0';
				else 
					count := 0;
				end if;

			end if;
			count := count + 1;
		end if;
end  process;
	
-- send output
process(nReset,output_val, clk_enable)
	begin
		if nReset = '1' then
			send <= '0';
		elsif rising_edge(clk_enable) then
			for index in 0 to 23 loop
				if output_val(index) = '1' then
					send <= '1';
				else
					send <= '0';
				end if;	
			end loop;
		end if;
end process;

	
	
end behaviour;

