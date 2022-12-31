LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.lcd_package.all;


entity top is
	
	port(
		--global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		-- avalon slave interface
		AS_Address : in std_logic_vector(15 downto 0);
		AS_CS : in std_logic;
		AS_Write : in std_logic;
		AS_Read : in std_logic;
		AS_DataWrite : in std_logic_vector(31 downto 0);
		AS_DataRead : out std_logic_vector(31 downto 0);

		-- avalon master interface(DMA)
		AM_Address : out std_logic_vector(31 downto 0);
		AM_ByteEnable : out std_logic;
		AM_Read : out std_logic;
		AM_ReadData : in std_logic_vector(7 downto 0);
		AM_ReadDataValid : in std_logic;
		AM_WaitRequest : in std_logic;
		
		--lcd signals(gpio)
		D : out std_logic_vector(15 downto 0);
		DCX : out std_logic;
		WRX : out std_logic;
		RESX : out  std_logic;
		CSX : out std_logic;

		-- debug signals
		debug_fifo_out : out std_logic;
		debug_lcd_state : out LCDFSM;
		debug_dma_state : out AcqState
	);

	
end top;


architecture top_architecture of top is
	-- internal signals linking internal modules
	signal signal_DataTransfer : std_logic_vector(15 downto 0);  	-- data to be sent to the fifo	
	signal signal_DataSend : std_logic; 							-- signal to send data to the fifo
	signal signal_FIFO_Almost_Full : std_logic; 					-- signal to indicate that the fifo is almost full
	signal signal_FIFO_Q : std_logic_vector(15 downto 0); 								-- fifo data output
	signal signal_FIFO_ReadReq : std_logic; 						-- signal to indicate that the fifo is ready to read
	signal signal_FIFO_Empty : std_logic; 							-- signal to indicate that the fifo is empty
	signal signal_reset_cmd : std_logic; 							-- signal to reset the command register
	signal signal_reset_reset : std_logic; 							-- signal to reset the reset register
	signal signal_img_length : std_logic_vector(31 downto 0); 		-- signal to indicate the length of the image
	signal signal_img_address : std_logic_vector(31 downto 0); 	-- signal to indicate the address of the image
	signal signal_flags : std_logic_vector(15 downto 0); 			-- signal to indicate the flags
	signal signal_cmd : std_logic_vector(15 downto 0); 				-- signal to indicate the command
	signal signal_nb_param : std_logic_vector(15 downto 0); 		-- signal to indicate the number of parameters
	signal signal_param : RF(0 to 63); 			-- signal to indicate the parameters
	signal signal_reset_flag_cmd : std_logic; 						-- signal to reset the flag command

	
	component AcquModule port(
			-- global signals
			clk : in std_logic;
			nReset : in std_logic;

			--Acquisition signals from DMA
			DataAcquisition : in std_logic_vector(7 downto 0);
			NewData : in std_logic := '0';
						
			-- Avalon Slave : 
			AS_Address : in std_logic_vector(15 downto 0); 
			AS_CS : in std_logic ; 
			AS_Write : in std_logic ; 
			AS_Read : in std_logic ; 
			AS_DataWrite : in std_logic_vector(31 downto 0) ; 
			AS_DataRead : out std_logic_vector(31 downto 0) ; 

			ResetFlagCMD : in std_logic ;
			ResetFlagReset : in std_logic ;
			--ResetFlagEnable : in std_logic ;

			-- LCD controller and DMA registers
			Reg_ImgAddress: out std_logic_vector(31 downto 0);
			Reg_ImgLength : out std_logic_vector(31 downto 0);
			Reg_Flags : out std_logic_vector(15 downto 0);
			Reg_Cmd : out std_logic_vector(15 downto 0);
			Reg_NbParam : out std_logic_vector(15 downto 0);
			Reg_Param : out RF(0 to 63);

			-- Avalon Master : 
			AM_Address : out std_logic_vector(31 downto 0);
			AM_ByteEnable : out std_logic;
			AM_Read : out std_logic;
			AM_WaitRequest : in std_logic;

			-- Output signals to FIFO
			DataTransfer : out std_logic_vector(15 downto 0);
			DataAck : out std_logic;    
			FIFO_Almost_Full : in std_logic;

			--debug signals
			debug_dma_state : out AcqState
		);
	end component;

	component fifo PORT(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full	: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ; --not needed
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0) --not needed
	);
    end component;

	component lcd_controller is
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
			LCD_q : in std_logic_vector(15 downto 0);
			LCD_ReadReq : out std_logic;
			LCD_Empty : in std_logic;
			
			-- Register Signals
			img_length : in std_logic_vector(31 downto 0);
			flag : in std_logic_vector(15 downto 0);
			command_reg : in std_logic_vector(15 downto 0);
			nb_param_reg : in std_logic_vector(15 downto 0);
			param : in RF(0 to 63);
		
			reset_flag_reset : out std_logic;
			reset_flag_cmd : out std_logic;

			--debug signals
			debug_lcd_state : out LCDFSM
			
			
		);
	end component;

	begin
	
	debug_fifo_out <= signal_FIFO_Empty;

	avalon_interface : component AcquModule
	port map(
	-- global signals
		clk => clk,								-- cpu -> acquisition
		nReset => nReset,						-- cpu -> acquisition
	-- Avalon Master interface
		AM_Address => AM_Address,				-- acquisition -> DMA
		AM_ByteEnable => AM_ByteEnable,			-- acquisition -> DMA
		AM_Read => AM_Read,						-- acquisition -> DMA
		AM_WaitRequest => AM_WaitRequest,		-- DMA -> acquisition
		NewData => AM_ReadDataValid,			-- DMA -> acquisition
		DataAcquisition => AM_ReadData,			-- DMA -> acquisition

		-- LCD controller and DMA registers
		ResetFlagCMD =>	signal_reset_cmd,		-- lcd controller -> acquisition
		ResetFlagReset => signal_reset_reset,	-- lcd controller -> acquisition
		Reg_ImgAddress => signal_img_address,	-- acquisition -> lcd controller
		Reg_ImgLength => signal_img_length,		-- acquisition -> lcd controller
		Reg_Flags => signal_flags,				-- acquisition -> lcd controller
		Reg_Cmd => signal_cmd,				-- acquisition -> lcd controller
		Reg_NbParam => signal_nb_param,			-- acquisition -> lcd controller
		Reg_Param => signal_param,				-- acquisition -> lcd controller

	-- Avalon Slave interface
		AS_Address => AS_Address,				-- cpu -> acquisition
		AS_CS => AS_CS,							-- cpu -> acquisition
		AS_Write => AS_Write,					-- cpu -> acquisition
		AS_Read => AS_Read,						-- cpu -> acquisition
		AS_DataWrite => AS_DataWrite,			-- cpu -> acquisition
		AS_DataRead => AS_DataRead,				-- acquisition -> cpu

	-- Output signals to FIFO
		DataTransfer => signal_DataTransfer,		-- acquisition -> fifo
		DataAck => signal_DataSend,					-- acquisition -> fifo
		FIFO_Almost_Full => signal_FIFO_Almost_Full,-- fifo -> acquisition
	
	-- Debug 
		debug_dma_state => debug_dma_state
	);

	-- FIFO
	fifo_inst : fifo
	port map(
		clock => clk,								-- cpu -> fifo
		data => signal_DataTransfer,				-- acquisition -> fifo
		rdreq => signal_FIFO_ReadReq,				-- lcd_controller -> fifo
		wrreq => signal_DataSend,					-- acquisition -> fifo
		almost_full => signal_FIFO_Almost_Full,		-- fifo -> acquisition
		empty => signal_FIFO_Empty,					-- fifo -> lcd_controller
		q => signal_FIFO_Q							-- fifo -> lcd_controller
	);

	-- LCD Controller
	lcd_controller_inst : lcd_controller
	port map(
		--global signals 
		clk => clk,								-- cpu -> lcd_controller
		nReset => nReset,						-- cpu -> lcd_controller

		-- output to LCD through GPIO
		D => D,									-- lcd_controller -> lcd
		DCX => DCX,								-- lcd_controller -> lcd
		CSX => CSX,								-- lcd_controller -> lcd
		RESX => RESX,							-- lcd_controller -> lcd
		WRX => WRX,								-- lcd_controller -> lcd

		-- FIFO 
		LCD_q => signal_FIFO_Q,					-- fifo -> lcd_controller
		LCD_ReadReq => signal_FIFO_ReadReq,		-- fifo -> lcd_controller
		LCD_Empty => signal_FIFO_Empty,			-- fifo -> lcd_controller

		-- Register Signals
		img_length =>  signal_img_length,		-- acquisition -> lcd_controller
		flag =>  signal_flags,					-- acquisition -> lcd_controller
		command_reg => signal_cmd,			-- acquisition -> lcd_controller
		nb_param_reg => signal_nb_param,		-- acquisition -> lcd_controller
		param => signal_param,					-- acquisition -> lcd_controller
		reset_flag_reset => signal_reset_reset,	-- lcd controller -> acquisition
		reset_flag_cmd => signal_reset_cmd,		-- lcd controller -> acquisition

		--debug signals
		debug_lcd_state => debug_lcd_state
		
	);

end architecture top_architecture ;
		
		
		
		