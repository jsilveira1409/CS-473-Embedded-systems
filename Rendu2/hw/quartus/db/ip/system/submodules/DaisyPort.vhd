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
		LEDPort 		: out std_logic
	);
end DaisyPort;


architecture behaviour of DaisyPort is 
	signal iRegD1			: std_logic_vector(31 downto 0);
	signal iRegD2			: std_logic_vector(31 downto 0);
	signal iRegD3			: std_logic_vector(31 downto 0);
	signal iRegD4			: std_logic_vector(31 downto 0);
	signal iRegD5			: std_logic_vector(31 downto 0);
	signal iRegD6			: std_logic_vector(31 downto 0);
	signal iRegD7			: std_logic_vector(31 downto 0);
	signal iRegD8			: std_logic_vector(31 downto 0);
	signal iRegD9			: std_logic_vector(31 downto 0);
	signal iRegD10			: std_logic_vector(31 downto 0);
	signal iRegD11			: std_logic_vector(31 downto 0);
	signal iRegD12 		: std_logic_vector(31 downto 0);
	signal iRegD13			: std_logic_vector(31 downto 0);
	signal iRegD14			: std_logic_vector(31 downto 0);
	signal iRegD15			: std_logic_vector(31 downto 0);
	signal iRegD16			: std_logic_vector(31 downto 0);
	signal output_val		: std_logic_vector(383 downto 0);
	signal output			: std_logic;
	signal next_send 		: std_logic;
	signal reset_diode	: std_logic;
		
begin
	
	
	-- Avalon slave write to registers.
	process(clk, nReset, Address)
		begin
			if nReset = '0' then
				iRegD1	<= (others => '0');
				iRegD2	<= (others => '0');
				iRegD3	<= (others => '0');
				iRegD4	<= (others => '0');
				iRegD5	<= (others => '0');
				iRegD6	<= (others => '0');
				iRegD7	<= (others => '0');
				iRegD8	<= (others => '0');
				iRegD9	<= (others => '0');
				iRegD10	<= (others => '0');
				iRegD11	<= (others => '0');
				iRegD12	<= (others => '0');
				iRegD13	<= (others => '0');
				iRegD14	<= (others => '0');
				iRegD15	<= (others => '0');
				iRegD16	<= (others => '0');
			elsif rising_edge(clk) then
				if write = '1' then
					case Address is
						when "0000" => iRegD1(23 downto 0)		 <= writedata(23 downto 0);
						when "0001" => iRegD2(23 downto 0)		 <= writedata(23 downto 0);
						when "0010" => iRegD3(23 downto 0)		 <= writedata(23 downto 0);
						when "0011" => iRegD4(23 downto 0)		 <= writedata(23 downto 0);
						when "0100" => iRegD5(23 downto 0)		 <= writedata(23 downto 0);
						when "0101" => iRegD6(23 downto 0)		 <= writedata(23 downto 0);
						when "0110" => iRegD7(23 downto 0)		 <= writedata(23 downto 0);
						when "0111" => iRegD8(23 downto 0)		 <= writedata(23 downto 0);
						when "1000" => iRegD9(23 downto 0)		 <= writedata(23 downto 0);
						when "1001" => iRegD10(23 downto 0)		 <= writedata(23 downto 0);
						when "1010" => iRegD11(23 downto 0)		 <= writedata(23 downto 0);
						when "1011" => iRegD12(23 downto 0)		 <= writedata(23 downto 0);
						when "1100" => iRegD13(23 downto 0)		 <= writedata(23 downto 0);
						when "1101" => iRegD14(23 downto 0)		 <= writedata(23 downto 0);
						when "1110" => iRegD15(23 downto 0)		 <= writedata(23 downto 0);
						when "1111" => iRegD16(23 downto 0)		 <= writedata(23 downto 0);
						
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
			index := 0;
			next_send <= '1';
			output <= '0';
			LEDPort <= '0';
			reset_diode <= '0';
			count := 1;
		elsif rising_edge(clk) then
			if write = '0' then
					if next_send = '1' then
						output <= output_val(index);
						index := index + 1;
						if index >= 383 then
							index := 0;
							count := 0;
							reset_diode <= '1';
						end if;
						next_send <= '0';
					end if;
					-- send data
					if next_send = '0' then
						if reset_diode = '0' then
						--send 0
							if output = '0' then
								if count <= 18 then
									LEDPort <= '1';
									count := count + 1;
								elsif count > 18 and count <= 58 then
									LEDPort <= '0';
									count := count + 1;
								else 
									count := 1;
									next_send <= '1';
								end if;
						
						-- send 1
							elsif output = '1' then
			
								if count <= 35 then
									LEDPort <= '1';
									count := count + 1;
								elsif count > 35 and count <= 65 then
									LEDPort <= '0';
									count := count + 1;
								else 
									count := 1;
									next_send <= '1';
								end if;

							end if;	
						end if;
						
						-- send reset
						if reset_diode = '1' then
							if count <= 3000 then
								LEDPort <= '0';
								count := count + 1;
							else 
								count := 1;
								reset_diode <= '0';
								next_send <= '1';
							end if;
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
			if write = '0' then				
				output_val(23 downto 0)    <= iRegD1(23 downto 0);
				output_val(47 downto 24)   <= iRegD2(23 downto 0);
				output_val(71 downto 48)   <= iRegD3(23 downto 0);
				output_val(95 downto 72)   <= iRegD4(23 downto 0);
				output_val(119 downto 96)  <= iRegD5(23 downto 0);
				output_val(143 downto 120) <= iRegD6(23 downto 0);
				output_val(167 downto 144) <= iRegD7(23 downto 0);
				output_val(191 downto 168) <= iRegD8(23 downto 0);
				output_val(215 downto 192) <= iRegD9(23 downto 0);
				output_val(239 downto 216) <= iRegD10(23 downto 0);
				output_val(263 downto 240) <= iRegD11(23 downto 0);
				output_val(287 downto 264) <= iRegD12(23 downto 0);
				output_val(311 downto 288) <= iRegD13(23 downto 0);
				output_val(335 downto 312) <= iRegD14(23 downto 0);
				output_val(359 downto 336) <= iRegD15(23 downto 0);
				output_val(383 downto 360) <= iRegD16(23 downto 0);
			end if;
		end if;

end process;
end behaviour;