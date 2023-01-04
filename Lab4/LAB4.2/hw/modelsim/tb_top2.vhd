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
    SIGNAL AM_ByteEnable :  std_logic;
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
        nReset <= '1';
        wait for CLK_PERIOD / 2;
        nReset <= '0';
    end procedure async_reset;	

    begin
        wait for CLK_PERIOD;

    async_reset;

--write
    AS_Address <= x"0004";
    AS_Write <= '1';
    AS_Read <= '0';
    AS_DataWrite <= x"0001";  
    wait for CLK_PERIOD * 4;
    AS_Write <= '0';
    
--read    
    AS_Address <= x"0004";
    AS_Write <= '0';
    AS_Read <= '1';
    AS_DataWrite <= x"AA11";  
    wait for CLK_PERIOD * 4;
    AS_Read <= '0';
    



    wait;

    end process simulation;
    end architecture test;