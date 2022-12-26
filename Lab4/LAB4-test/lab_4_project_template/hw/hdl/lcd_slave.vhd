library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lcd_package.all;

entity lcd_slave is

	port (
		-- global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		-- lcd_controller and DMA registers
		img_address : out std_logic_vector(31 downto 0);
		img_length : out std_logic_vector(31 downto 0);
		flag : out std_logic_vector(15 downto 0);
		cmd_reg : out std_logic_vector(15 downto 0);
		nb_param_reg : out std_logic_vector(15 downto 0);
		param : out RF(0 to 63);
		
		-- avalon slave imginternal interfaces
		address : in std_logic_vector( 6 downto 0 );
		write : in std_logic;
		read : in std_logic;
		writedata : in std_logic_vector(15 downto 0);
		readdata : out std_logic_vector(15 downto 0);
		
		reset_flag_cmd : in std_logic;
		reset_flag_enable : in std_logic;
		reset_flag_reset : in std_logic
		
	);
end lcd_slave;

architecture lcd_slave_architecture of lcd_slave is

	signal reg : RF(0 to 70);

begin


	process(clk)
	
	begin
		if rising_edge(clk) then
			readdata <= (others => '0');
			
			if read = '1' then
			
				case to_integer(unsigned(address)) is 
					when 0 to 70 => readdata <= reg (to_integer(unsigned(address)));
					when others => null;
				end case;
				
			end if;
		end if;
	
	end process;

	process(clk, nReset)
	
		variable tmp : RF(0 to 70);
		
	begin
		if nReset = '0' then
			tmp := (others => (others => '0'));
			
		elsif rising_edge(clk) then
		
			tmp := reg;
			
			if write = '1' then
				case to_integer(unsigned(address)) is
					when 0 to 70 => tmp(to_integer(unsigned(address))) := writedata;
					when others => NULL;
				end case;
			end if;
		
			
		if reset_flag_cmd = '0' then
			tmp(4)(1) := '0';
		end if;
		
		if reset_flag_reset = '0' then
			tmp(4)(2) := '0';
		end if;
		
		if reset_flag_enable = '0' then
			tmp(4)(0) := '0';
		end if;
		
		reg <= tmp;
		end if;
	end process;

	
end;