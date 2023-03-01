library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lcd_package.all;

entity tb_top is
end tb_top;

architecture test of tb_top is

    CONSTANT CLK_PERIOD : time := 20 ns;
    --global signals
    SIGNAL clk : std_logic;
    SIGNAL nReset : std_logic;

    -- avalon slave terface
    SIGNAL AS_Address :  std_logic_vector(15 downto 0);
    SIGNAL AS_CS :  std_logic;
    SIGNAL AS_Write :  std_logic;
    SIGNAL AS_Read :  std_logic;
    SIGNAL AS_DataWrite :  std_logic_vector(15 downto 0);
    SIGNAL AS_DataRead :  std_logic_vector(15 downto 0);
    -- avalon master terface(DMA)
    SIGNAL AM_Address :  std_logic_vector(31 downto 0);
    SIGNAL AM_Read :  std_logic;
    SIGNAL AM_ReadData :  std_logic_vector(15 downto 0);
    SIGNAL AM_ReadDataValid :  std_logic;
    SIGNAL AM_WaitRequest :  std_logic;

    --lcd signals(gpio)
    SIGNAL D :  std_logic_vector(15 downto 0);
    SIGNAL DCX :  std_logic;
    SIGNAL WRX :  std_logic;
    SIGNAL RESX :   std_logic;
    SIGNAL CSX :  std_logic;
    
    -- debug
    signal debug : std_logic_vector(15 downto 0);
    SIGNAL debug_fifo_out_empty : std_logic;
    SIGNAL debug_fifo_out_full : std_logic;
    signal debug_fifo_out_q : std_logic_vector(15 downto 0);
    signal debug_fifo_usedw : std_logic_vector(7 downto 0);
    SIGNAL debug_lcd_state : LCDFSM;
    SIGNAL debug_dma_state : AcqState;
    signal debug_acq_data_transfer : std_logic_vector(15 downto 0);

begin

top : entity work.top
    port map(
        clk => clk,
        nReset => nReset,

        AS_Address => AS_Address,
        --AS_CS => AS_CS,
        AS_Write => AS_Write,
        AS_Read => AS_Read,
        AS_DataWrite => AS_DataWrite,
        AS_DataRead => AS_DataRead,

        AM_Address => AM_Address,
        AM_Read => AM_Read,
        AM_ReadData => AM_ReadData,
        AM_ReadDataValid => AM_ReadDataValid,
        AM_WaitRequest => AM_WaitRequest,

        D => D,
        DCX => DCX,
        WRX => WRX,
        RESX => RESX,
        CSX => CSX,
        debug => debug,
        debug_fifo_out_empty => debug_fifo_out_empty,
        debug_fifo_out_full => debug_fifo_out_full,
        debug_lcd_state => debug_lcd_state,
        debug_dma_state => debug_dma_state,
        debug_fifo_out_q => debug_fifo_out_q,
        debug_fifo_usedw => debug_fifo_usedw,
        debug_acq_data_transfer => debug_acq_data_transfer

    );

    clk_gen : process
	begin
		clk <= '1';
		wait for CLK_PERIOD / 2;
		clk <= '0';
		wait for CLK_PERIOD / 2;
	end process clk_gen;    

    simulation : process
    procedure async_reset is
    begin
        wait until rising_edge(clk);
        wait for CLK_PERIOD / 4;
        nReset <= '0';
        wait for CLK_PERIOD * 2;
        nReset <= '1';
        --Flags <= x"0000";
        --CommandReg <= x"0000";
        --NParamReg <= x"0000";
        --Params <= (others => x"0000");
    end procedure async_reset;	

    begin
        wait for CLK_PERIOD;

--		-- Reset procedure
--		Flags(2) <= '1';
--
--		wait until reset_flag_reset = '0';
--		Flags(2) <= '0';
--
--		-- Sending 2 commands to LT24
--		CommandReg <= x"00aa";
--		NParamReg <= x"0003";
--		Params(0) <= x"1111";
--		Params(1) <= x"2222";
--		Params(2) <= x"3333";
--		Flags(1) <= '1';
--		wait until reset_flag_cmd = '0';
--		Flags(1) <= '0';
--		wait for CLK_PERIOD;
--		CommandReg <= x"00bb";
--		NParamReg <= x"0002";
--		Params(0) <= x"3333";
--		Params(1) <= x"4444";
--		Flags(1) <= '1';
--		wait until reset_flag_cmd = '0';
--		Flags(1) <= '0';
--		wait for CLK_PERIOD;


-- async reset
    async_reset;
    AS_Address <= x"0004";      -- 0b0000000000001010
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0004";  
    wait for 10000us;









-- send command
    --set cmd reg to cmd 0x11
    AS_Address <= x"0005";      -- 0b0000000000001010
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"AA11";  
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';
    -- set cmd nb param to 0
    AS_Address <= x"0006";      -- 0b0000000000001010
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0000";    -- 0b0000000000000000
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';
    -- set cmd param to 0
    --AS_Address <= x"000E";      -- 0b0000000000001010
    --AS_CS <= '1';
    --AS_Write <= '1';
    --AS_Read <= '0';
    --AS_DataWrite <= x"00000000";    -- 0b0000000000000000
    --wait for CLK_PERIOD * 2;
    --AS_CS <= '0';
    --wait for CLK_PERIOD * 4;
    
    -- send command flag
    AS_Address <= x"0004";      -- 0b0000000000001000
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0002";    -- 0b0000000000000010
    
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';


-- Image address register 
    AS_Address <= x"0000";      -- 0b0000000000000100
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"000A";    -- 0b0000000000001010
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';

-- Image length register 
    --set to 10 (bytes ? )
    AS_Address <= x"0001";      -- 0b0000000000000010
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0010";    
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';

-- Image length register 
    --set to 10 (bytes ? )
    AS_Address <= x"0002";      -- 0b0000000000000010
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0000";    
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0';    

-- AS flag register
    -- set lcd enable bit( = flag_reg(0)) to 1 in AS
    AS_Address <= x"0003";      -- 0b0000000000001000
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"00FF";    -- 0b0000000000000001
    
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	--AS_Read <= '0'; 

    AS_Address <= x"0004";      -- 0b0000000000001000
    --AS_CS <= '1';
    AS_Write <= '1';
    --AS_Read <= '0';
    AS_DataWrite <= x"0001";    -- 0b0000000000000010
    
    wait for CLK_PERIOD * 2;
   -- AS_CS <= '0';
    AS_Read <= '1';
    wait for CLK_PERIOD * 2;   
	AS_Read <= '0';

  --  -- Simulating Slave response to DMA request
 --  wait until read = '1';
    AM_ReadDatavalid <= '1';
    AM_WaitRequest <= '0';
    AM_ReadData <= x"0011";       -- 0b00010001
    --wait for CLK_PERIOD * 2;
    --AM_ReadDatavalid <= '0';
   -- wait for CLK_PERIOD * 4;
    --AM_ReadDatavalid <= '1';
    wait for CLK_PERIOD;
    AM_ReadData <= x"0022";       -- 0b00010010
    wait for CLK_PERIOD;
    AM_ReadData <= x"0033";       -- 0b00010011
    wait for CLK_PERIOD;
    AM_ReadData <= x"0044";       -- 0b00010100
    wait for CLK_PERIOD;
    AM_ReadData <= x"0055";       -- 0b00010101
    wait for CLK_PERIOD;
    AM_ReadData <= x"0066";       -- 0b00010110
    wait for CLK_PERIOD;
    AM_ReadData <= x"0077";       -- 0b00010111
    wait for CLK_PERIOD;
    AM_ReadData <= x"0088";       -- 0b00011000
    wait for CLK_PERIOD;
    AM_ReadData <= x"0099";       -- 0b00011001
    wait for CLK_PERIOD;
    AM_ReadData <= x"00AA";       -- 0b00011010
    wait for CLK_PERIOD;
    AM_ReadData <= x"00BB";       -- 0b00011011
    wait for CLK_PERIOD;
    AM_ReadData <= x"00CC";       -- 0b00011100
    wait for CLK_PERIOD;
    AM_ReadData <= x"00DD";       -- 0b00011101
    wait for CLK_PERIOD;
    AM_ReadData <= x"00EE";       -- 0b00011110
    wait for CLK_PERIOD;
    AM_ReadData <= x"00FF";       -- 0b00011111
    wait for CLK_PERIOD;
    AM_ReadDatavalid <= '0';
    wait for CLK_PERIOD*2;
    AM_ReadDatavalid <= '1';
  --  -- Second burst of pixels
    wait for CLK_PERIOD * 2;
    AM_WaitRequest <= '0';
    AM_ReadData <= x"0011";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0022";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0033";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0044";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0055";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0066";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0077";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0088";
    wait for CLK_PERIOD;
    AM_ReadData <= x"0099";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00AA";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00BB";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00CC";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00DD";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00EE";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00FF";
    wait for CLK_PERIOD;
    AM_ReadData <= x"00CD";
    wait for CLK_PERIOD;
    AM_ReadDatavalid <= '0';
--
    --wait until reset_flag_lcdenable = '0';
    --Flags(0) <= '0';


    wait;

    end process simulation;
    end architecture test;