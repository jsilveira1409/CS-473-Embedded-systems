library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lcd_package.all;


entity lcd_controller is

	port(
		-- global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		-- output to LCD through GPIO
		D : out std_logic_vector(15 downto 0);
		DCX : out std_logic;
		CSX : out std_logic;
		RESX : out std_logic;
		WRX : out std_logic;
		
		-- FIFO input signals
		fifo_q : in std_logic_vector(15 downto 0);
		fifo_read_req : out std_logic;
		fifo_empty : in std_logic;
		
		-- Register Signals
		img_length : in std_logic_vector(31 downto 0);
		flag : in std_logic_vector(15 downto 0);
		command_reg : in std_logic_vector(15 downto 0);
		nb_param_reg : in std_logic_vector(15 downto 0);
		param : in RF(0 to 63);
		
		reset_flag_reset : out std_logic;
		reset_flag_cmd : out std_logic;
		
		-- Debug signals
		lcd_current_state_out : out LCDFSM
		
	);
	
	end lcd_controller;
	
	
	architecture arch_lcd_controller of lcd_controller is 
		signal reset_cnt : unsigned(31 downto 0);
		signal current_param : unsigned(7 downto 0);
		
		signal clock_cycles : unsigned(3 downto 0);
		
		signal bytes_remaining : unsigned(31 downto 0);
		signal current_state : LCDFSM := Idle;
		signal last_val : std_logic := '0';
		
	begin
	
	CSX <= '0';
	
	
		-- FSM for the LCD controller
		process (clk, nReset, flag, command_reg, nb_param_reg, param, current_param, fifo_empty, img_length)
		
			variable bytes_left: unsigned(31 downto 0);
			
		begin
			if flag(2) = '1' and current_state /= Reset then
			
				current_state <= Reset;
				
			elsif nReset ='0' then
			
				current_state <= IDLE;
				D <= x"0000";
				DCX <= '0';
				WRX <= '0';
				RESX <= '0';
				CSX <= '0';
				
				clock_cycles <= x"000";
				current_param <= x"00";
				reset_cnt <= x"00000000";
				reset_flag_reset <= '1';
				reset_flag_cmd <= '1';
				
				
			elsif rising_edge(clk) then
				case current_state is
					when RESET 	=>
						-- EXECUTE RESET AS DESCRIBED BY THE DATASHEET
						WRX <= '0';
						if reset_cnt < 50000  then
							RESX <= '0';
							reset_cnt <= reset_cnt + 1;
							reset_flag_reset <= '1';
							current_state <= RESET;
							
						elsif reset_cnt <550000 then
							RESX <= '1';
							reset_cnt <= reset_cnt + 1;
							current_state <= RESET;
							reset_flag_reset <= '1';
							
						elsif reset_cnt < 6550000 then
							RESX <= '0';
							reset_cnt <= reset_cnt + 1;
							current_state <= RESET;
							reset_flag_reset <= '1';
							
							
						elsif reset_cnt = 6550000 then
							RESX <= '0';
							reset_flag_reset <= '0';
							reset_cnt <= reset_cnt + 1;
							current_state <= RESET;
							
						else 
							RESX <= '1';
							reset_flag_reset <= '0';
							current_state <= IDLE;
							reset_cnt <= x"00000000";
						end if;
						
					when IDLE 	=>
						WRX <= '0';
						reset_flag_cmd <= '1';
						reset_flag_reset <= '1';
						
						if flag(1) = '1' then
							current_state <= CMD_READ;
						elsif flag(0) = '1' then
							current_state <= IMG_DISPLAY;
						else
							current_state <= IDLE;
						end if;
						
					when CMD_READ =>
						DCX <= '0';
						WRX <= '0';
						D <= command_reg;
						current_param <= x"00";
						
						if (clock_cycles) < 5 then
							clock_cycles <= clock_cycles + 1;
							current_state <= CMD_READ;
						else 
							clock_cycles <= x"000";
							current_state <= CMD_SEND;
						end if;
						
					when CMD_SEND =>
						WRX <= '1';
						
						if current_param = unsigned(nb_param_reg) then
							clock_cycles <= x"000";
							reset_flag_cmd <= '0';
							current_state <= RESET_REGS;
						elsif clock_cycles < 5 then
							clock_cycles <= clock_cycles + 1;
							current_state <= CMD_SEND;
						else 
							current_state <= PARAM_GET;
							clock_cycles <= x"000";
						end if;							
						
					when PARAM_GET =>
						WRX <= '1';
						DCX <= '1';
						D <= param(to_integer(current_param));
						
						if clock_cycles < 5 then
							current_state <= PARAM_GET;
							clock_cycles <= clock_cycles + 1;
						else
							current_param <= current_param + 1;
							clock_cycles <= x"000";
							current_state <= CMD_SEND;
						end if;
						
					when RESET_REGS =>
						if clock_cycles < 5 then
							current_state <= RESET_REGS;
							clock_cycles <= clock_cycles + 1;
						else
							clock_cycles <= clock_cycles + 1;
							current_state <= IDLE;
						end if;
						
					when IMG_DISPLAY =>
						WRX <= '0';
						bytes_remaining <= unsigned(img_length);
						
						if flag(0) = '0' then
							current_state <= IDLE;
						elsif fifo_empty = '0' then
							current_state <= PIXEL_WRITE;
						else
							current_state <= IMG_DISPLAY;
						end if;						
					
					when PIXEL_WRITE =>
						WRX <= '0';
						DCX <= '0';
						-- pixel write command CHECK
						D <= x"002c";
						
						if clock_cycles < 5 then
							clock_cycles <= clock_cycles + 1;
							current_state <= PIXEL_WRITE;
						else 
							current_state <= IMG_DISPLAY;
							clock_cycles <= "000";
						end if;
					
					when PIXEL_GET =>
						DCX <= '1';
						WRX <= '0';
						
						if clock_cycles < 2 then
							fifo_read_req <= '0';
							clock_cycles <= clock_cycles + 1;
							current_state <= PIXEL_GET;
						elsif clock_cycles = 2 then
							fifo_read_req <= '1';
							clock_cycles <= clock_cycles + 1;
							current_state <= PIXEL_GET;
						elsif clock_cycles = 3 then
							clock_cycles <=  clock_cycles + 1;
							current_state <= PIXEL_GET;
							fifo_read_req <= '0';
							D <= fifo_q;
						else 
							clock_cycles <= "000";
							current_state <= PIXEL_WRITE;
							fifo_read_req <= '0';
						end if;
				end case;
			end if;
		end process;
	
	lcd_current_state_out <= current_state;
		
		
	end arch_lcd_controller;