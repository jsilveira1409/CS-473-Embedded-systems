LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.lcd_package.all;


entity top is
	
	port(
		--global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		-- avalon master interface(DMA)
		address : out std_logic_vector(31 downto 0);
		read : out std_logic;
		readdata : in std_logic_vector(15 downto 0);
		readdatavalid : in std_logic;
		wait_req : in std_logic;
		burstcount : out std_logic_vector(4 downto 0);
		
		-- avalon slave interface(lcd_slave)
		address_slave : in std_logic_vector(6 downto 0);
		write : in std_logic;
		read_slave : in std_logic;
		writedata : in std_logic_vector(15 downto 0 );
		readdata_slave : out std_logic_vector(15 downto 0);
		
		--lcd signals(gpio)
		D : out std_logic_vector(15 downto 0);
		DCX : out std_logic;
		WRX : out std_logic;
		RESX : out  std_logic;
		CSX : out std_logic
	);
	
end top;


architecture top_architecture of top is

	component lcd_controller port(
		clk : in std_logic;
		nReset : in std_logic;
		
		-- slave interface signals
		img_length : in std_logic_vector(31 downto 0);
		flag : in std_logic_vector(15 downto 0);
		cmd_reg : in std_logic_vector(15 downto 0);
		nb_param : in std_logic_vector (15 downto 0);
		param : in RF;
		
		reset_flag_reset : out std_logic;
		reset_flag_cmd : out std_logic;
		
		-- fifo
		fifo_q : in std_logic_vector(15 downto 0);
		fifo_read_req : out std_logic;
		fifo_empty : in std_logic;
		
		-- outputs
		D: out std_logic_vector(15 downto 0);
		DCX : out std_logic;
		CSX : out std_logic;
		RESX : out std_logic;
		WRX : out std_logic
		
	);
	end component lcd_controller;
	
	component acq_controller 
		port(
			clk : in std_logic;
			nReset : in std_logic;
			
			-- slave interface signals
			flag : in std_logic_vector(15 downto 0);
			img_address : in std_logic_vector(31 downto 0);
			img_length : in std_logic_vector(31 downto 0);
			reset_flag_enable : out std_logic;
			
			-- master interface signals
			address : out std_logic_vector(31 downto 0);
			read : out std_logic;
			readdata : in std_logic_vector(15 downto 0);
			readdatavalid : in std_logic;
			wait_req : in std_logic;
			
			burstcount : out std_logic_vector(4 downto 0);
			
			--signals to fifo
			fifo_data: out std_logic_vector(15 downto 0);
			fifo_write_req : out std_logic;
			fifo_almost_full : in std_logic
		) ;
		
	end component acq_controller;
	
	
	component lcd_slave 
		port(
			clk : in std_logic;
			nReset : in std_logic;
			
			--slave interface
			address : in std_logic_vector(6 downto 0);
			write: in std_logic;
			read : in std_logic;
			writedata: in std_logic_vector(15 downto 0);
			readdata: out std_logic_vector(15 downto 0);
			
			--output regs for controller and dma
			img_address : out std_logic_vector(31 downto 0);
			img_length : out std_logic_vector(31 downto 0);
			flag : out std_logic_vector( 15 downto 0);
			cmd_reg : out std_logic_vector(15 downto 0);
			nb_param_reg : out std_logic_vector(15 downto 0);
			param : out RF;
			
			reset_flag_reset : in std_logic;
			reset_flag_cmd : in std_logic;
			reset_flag_enable :in std_logic
			
		);
	end component lcd_slave;
	
	
	component fifo 
		port(
			clk : in std_logic;
			data : in std_logic_vector(15 downto 0);
			read_req : in std_logic;
			write_req : in std_logic;
			almost_full : out std_logic;
			empty : out std_logic;
			full : out std_logic;
			q : out std_logic_vector( 15 downto 0);
			usedw : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal img_length_tmp : std_logic_vector(31 downto 0);
	signal flag_tmp : std_logic_vector(15 downto 0);
	signal img_address_tmp : std_logic_vector(31 downto 0);
	signal cmd_reg_tmp : std_logic_vector(15 downto 0);
	signal nb_param_tmp : std_logic_vector(15 downto 0);
	signal param_tmp : RF (0 to 63);
	signal reset_flag_reset_tmp : std_logic;
	signal reset_flag_cmd_tmp : std_logic;
	signal reset_flag_enable_tmp : std_logic;
	
	signal fifo_data_tmp : std_logic_vector(15 downto 0);
	signal write_req_tmp : std_logic;
	signal read_req_tmp : std_logic;
	signal almost_full_tmp : std_logic;
	signal empty_tmp : std_logic;
	signal q_tmp : std_logic_vector(15 downto 0);
	
	
	begin
	
	slave_interface_instance : component lcd_slave
		port map(
			clk => clk,
			nReset => nReset,
			address => address_slave,
			write => write, 
			read => read_slave, 
			writedata => writedata,
			readdata => readdata_slave,
			img_address => img_address_tmp,
			img_length => img_length_tmp,
			flag => flag_tmp,
			cmd_reg => cmd_reg_tmp,
			nb_param_reg => nb_param_tmp,
			param => param_tmp,
			reset_flag_reset => reset_flag_reset_tmp,
			reset_flag_cmd => reset_flag_cmd_tmp,
			reset_flag_enable => reset_flag_enable_tmp
		);


	fifo_instance : component fifo
		port map(
			clk => clk,
			data => fifo_data_tmp,
			write_req => write_req_tmp,
			read_req => read_req_tmp,
			almost_full => almost_full_tmp,
			empty => empty_tmp,
			q => q_tmp
		);
		
	acq_instance : component acq_controller
		port map(
			clk => clk,
			nReset => nReset,
			flag => flag_tmp,
			img_address => img_address_tmp,
			img_length => img_length_tmp,
			reset_flag_enable => reset_flag_enable_tmp,
			AS_Address => address,
			read => read,
			readdata => readdata,
			readdatavalid => readdatavalid,
			wait_req => wait_req,
			burstcount => burstcount,
			fifo_data => fifo_data_tmp,
			fifo_write_req => write_req_tmp,
			fifo_almost_full => almost_full_tmp
		);
		
	lcd_instance : component lcd_controller
		port map(
			clk => clk,
			nReset => nReset, 
			img_length =>img_length_tmp,
			flag => flag_tmp,
			cmd_reg => cmd_reg_tmp,
			nb_param => nb_param_tmp,
			param => param_tmp,
			reset_flag_reset => reset_flag_reset_tmp,
			reset_flag_cmd => reset_flag_cmd_tmp,
			fifo_q => q_tmp,
			fifo_read_req => read_req_tmp,
			fifo_empty => empty_tmp,
			D => D,
			DCX => DCX,
			WRX => WRX, 
			CSX => CSX,
			RESX =>RESX
		);


end architecture top_architecture ;
		
		
		
		