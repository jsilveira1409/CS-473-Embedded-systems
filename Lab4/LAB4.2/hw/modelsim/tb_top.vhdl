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
    SIGNAL AS_DataWrite :  std_logic_vector(31 downto 0);
    SIGNAL AS_DataRead :  std_logic_vector(31 downto 0);
    -- avalon master terface(DMA)
    SIGNAL AM_Address :  std_logic_vector(31 downto 0);
    SIGNAL AM_ByteEnable :  std_logic;
    SIGNAL AM_Read :  std_logic;
    SIGNAL AM_ReadData :  std_logic_vector(7 downto 0);
    SIGNAL AM_ReadDataValid :  std_logic;
    SIGNAL AM_WaitRequest :  std_logic;

    --lcd signals(gpio)
    SIGNAL D :  std_logic_vector(15 downto 0);
    SIGNAL DCX :  std_logic;
    SIGNAL WRX :  std_logic;
    SIGNAL RESX :   std_logic;
    SIGNAL CSX :  std_logic;
    
    -- debug
    SIGNAL debug_fifo_out : std_logic;
    SIGNAL debug_lcd_state : LCDFSM;
    SIGNAL debug_dma_state : AcqState;

begin

top : entity work.top
    port map(
        clk => clk,
        nReset => nReset,

        AS_Address => AS_Address,
        AS_CS => AS_CS,
        AS_Write => AS_Write,
        AS_Read => AS_Read,
        AS_DataWrite => AS_DataWrite,
        AS_DataRead => AS_DataRead,

        AM_Address => AM_Address,
        AM_ByteEnable => AM_ByteEnable,
        AM_Read => AM_Read,
        AM_ReadData => AM_ReadData,
        AM_ReadDataValid => AM_ReadDataValid,
        AM_WaitRequest => AM_WaitRequest,

        D => D,
        DCX => DCX,
        WRX => WRX,
        RESX => RESX,
        CSX => CSX,

        debug_fifo_out => debug_fifo_out,
        debug_lcd_state => debug_lcd_state,
        debug_dma_state => debug_dma_state

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
        wait for CLK_PERIOD / 2;
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

-- Restart display
    --AS_Address <= x"0008";
    --AS_CS <= '1';
    --AS_Write <= '1';
    --AS_Read <= '0';
    --AS_DataWrite <= x"00000004";
    --wait for CLK_PERIOD * 2;
    --AS_CS <= '0';
    --wait for CLK_PERIOD * 10;
--
    --AS_Address <= x"0008";
    --AS_CS <= '1';
    --AS_Write <= '1';
    --AS_Read <= '0';
    --AS_DataWrite <= x"00000000";
    --wait for CLK_PERIOD * 2;
    --AS_CS <= '0';
    --wait for CLK_PERIOD * 10;

    
-- Image length register 
    --set to 10 (bytes ? )
    AS_Address <= x"0004";
    AS_CS <= '1';
    AS_Write <= '1';
    AS_Read <= '0';
    AS_DataWrite <= x"0000000A";
    wait for CLK_PERIOD * 2;
    AS_CS <= '0';
    wait for CLK_PERIOD * 4;

-- Image address register 
    --set to 0x0
    AS_Address <= x"0000";
    AS_CS <= '1';
    AS_Write <= '1';
    AS_Read <= '0';
    AS_DataWrite <= x"00000000";
    wait for CLK_PERIOD * 2;
    AS_CS <= '0';
    wait for CLK_PERIOD * 4;



-- AS flag register
    -- set lcd enable bit( = flag_reg(0)) to 1 in AS
    AS_Address <= x"0008";
    AS_CS <= '1';
    AS_Write <= '1';
    AS_Read <= '0';
    AS_DataWrite <= x"00000001";
    
    wait for CLK_PERIOD * 2;
    AS_CS <= '0';
    wait for CLK_PERIOD * 4;   


  --  -- Simulating Slave response to DMA request
 --  wait until read = '1';
    wait for CLK_PERIOD * 2;
    AM_WaitRequest <= '0';
    AM_ReadData <= x"11";
    AM_ReadDatavalid <= '0';
    wait for CLK_PERIOD * 4;
    AM_ReadDatavalid <= '1';
    wait for CLK_PERIOD;
    AM_ReadData <= x"22";
    wait for CLK_PERIOD;
    AM_ReadData <= x"33";
    wait for CLK_PERIOD;
    AM_ReadData <= x"44";
    wait for CLK_PERIOD;
    AM_ReadData <= x"55";
    wait for CLK_PERIOD;
    AM_ReadData <= x"66";
    wait for CLK_PERIOD;
    AM_ReadData <= x"77";
    wait for CLK_PERIOD;
    AM_ReadData <= x"88";
    wait for CLK_PERIOD;
    AM_ReadData <= x"99";
    wait for CLK_PERIOD;
    AM_ReadData <= x"AA";
    wait for CLK_PERIOD;
    AM_ReadData <= x"BB";
    wait for CLK_PERIOD;
    AM_ReadData <= x"CC";
    wait for CLK_PERIOD;
    AM_ReadData <= x"DD";
    wait for CLK_PERIOD;
    AM_ReadData <= x"EE";
    wait for CLK_PERIOD;
    AM_ReadData <= x"FF";
    wait for CLK_PERIOD;
    AM_ReadData <= x"CD";
    wait for CLK_PERIOD;
    AM_ReadDatavalid <= '0';
--
  --  -- Second burst of pixels
    --wait until read = '1';
    wait for CLK_PERIOD * 2;
    AM_WaitRequest <= '0';
    AM_ReadData <= x"11";
    AM_ReadDatavalid <= '0';
    wait for CLK_PERIOD * 4;
    AM_ReadDatavalid <= '1';
    wait for CLK_PERIOD;
    AM_ReadData <= x"22";
    wait for CLK_PERIOD;
    AM_ReadData <= x"33";
    wait for CLK_PERIOD;
    AM_ReadData <= x"44";
    wait for CLK_PERIOD;
    AM_ReadData <= x"55";
    wait for CLK_PERIOD;
    AM_ReadData <= x"66";
    wait for CLK_PERIOD;
    AM_ReadData <= x"77";
    wait for CLK_PERIOD;
    AM_ReadData <= x"88";
    wait for CLK_PERIOD;
    AM_ReadData <= x"99";
    wait for CLK_PERIOD;
    AM_ReadData <= x"AA";
    wait for CLK_PERIOD;
    AM_ReadData <= x"BB";
    wait for CLK_PERIOD;
    AM_ReadData <= x"CC";
    wait for CLK_PERIOD;
    AM_ReadData <= x"DD";
    wait for CLK_PERIOD;
    AM_ReadData <= x"EE";
    wait for CLK_PERIOD;
    AM_ReadData <= x"FF";
    wait for CLK_PERIOD;
    AM_ReadData <= x"CD";
    wait for CLK_PERIOD;
    AM_ReadDatavalid <= '0';
--
    --wait until reset_flag_lcdenable = '0';
    --Flags(0) <= '0';


    wait;



    end process simulation;
    end architecture test;