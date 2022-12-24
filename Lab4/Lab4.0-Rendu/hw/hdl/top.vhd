LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.lcd_package.all;


entity top_entity is
	
	port(
		--global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		
		-- avalon slave interface
		AS_Address : in std_logic;
		AS_CS : in std_logic;
		AS_Write : in std_logic;
		AS_Read : in std_logic;
		AS_DataWrite : in std_logic_vector(31 downto 0);
		AS_DataRead : out std_logic_vector(31 downto 0);
		AS_NewData : in std_logic;

		-- avalon master interface(DMA)
		AM_Address : out std_logic_vector(31 downto 0);
		AM_ByteEnable : out std_logic_vector(3 downto 0);
		AM_Read : out std_logic;
		AM_DataRead : in std_logic_vector(7 downto 0);
		AM_WaitRequest : in std_logic;
		
		--lcd signals(gpio)
		D : out std_logic_vector(15 downto 0);
		DCX : out std_logic;
		WRX : out std_logic;
		RESX : out  std_logic;
		CSX : out std_logic
	);
	
end top_entity;


architecture top_architecture of top_entity is
	-- internal signals linking internal modules
	signal DataTransfer : std_logic_vector(15 downto 0);  	-- data to be sent to the fifo	
	signal DataSend : std_logic; 							-- signal to send data to the fifo
	signal FIFO_Almost_Full : std_logic; 					-- signal to indicate that the fifo is almost full


	component AcquModule port(
			-- global signals
			clk : in std_logic;
			nReset : in std_logic;

			--Acquisition signals from DMA
			DataAcquisition : out std_logic_vector(7 downto 0);
			NewData : in std_logic := '0';
			ImageDone : in std_logic;
						
			-- Avalon Slave : 
			AS_Address : in std_logic; 
			AS_CS : in std_logic ; 
			AS_Write : in std_logic ; 
			AS_Read : in std_logic ; 
			AS_DataWrite : in std_logic_vector(31 downto 0) ; 
			AS_DataRead : out std_logic_vector(31 downto 0) ; 

			-- Avalon Master : 
			AM_Address : out std_logic_vector(31 downto 0);
			AM_ByteEnable : out std_logic_vector(3 downto 0);
			AM_Read : out std_logic;
			AM_DataRead : in std_logic_vector(7 downto 0);
			AM_WaitRequest : in std_logic;

			-- Output signals to FIFO
			DataTransfer : out std_logic_vector(15 downto 0);
			DataSend : out std_logic;    
			FIFO_Almost_Full : in std_logic
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



	begin
	
	
	avalon_interface : component AcquModule
	port map(
	-- global signals
		clk => clk,
		nReset => nReset,
	-- Avalon Master interface
		AM_Address => AM_Address,
		AM_ByteEnable => AM_ByteEnable,
		AM_Read => AM_Read,
		AM_DataRead => AM_DataRead,
		AM_WaitRequest => AM_WaitRequest,
	-- Avalon Slave interface
		AS_Address => AS_Address,
		AS_CS => AS_CS,
		AS_Write => AS_Write,
		AS_Read => AS_Read,
		AS_DataWrite => AS_DataWrite,
		AS_DataRead => AS_DataRead,
		NewData => AS_NewData,
	-- Output signals to FIFO
		DataTransfer => DataTransfer,
		DataSend => DataSend,
		FIFO_Almost_Full => FIFO_Almost_Full
	);

	-- FIFO
	fifo_inst : fifo
	port map(
		clock => clk,
		data => DataTransfer,
		rdreq => '0',
		wrreq => DataSend,
		almost_full => FIFO_Almost_Full,
		empty => '0',
		full => '0',
		q => D,
		usedw => '0'
	);


end architecture top_architecture ;
		
		
		
		