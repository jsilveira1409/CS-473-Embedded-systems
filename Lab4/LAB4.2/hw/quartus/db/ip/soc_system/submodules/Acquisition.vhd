LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;
use work.lcd_package.all;


entity AcquModule is
    port(
    clk : in std_logic;
    nReset : in std_logic;

    -- Acquisition 
    DataAcquisition : in std_logic_vector(15 downto 0) ; 
    NewData : in std_logic ; 

    -- Avalon Slave : 
    AS_Address : in std_logic_vector(15 downto 0); 
    AS_Write : in std_logic ; 
    AS_Read : in std_logic ; 
    AS_DataWrite : in std_logic_vector(15 downto 0) ; 
    AS_DataRead : out std_logic_vector(15 downto 0) ; 

    
    -- LCD controller and DMA registers
    Reg_ImgAddress: out std_logic_vector(31 downto 0);
    Reg_ImgLength : out std_logic_vector(31 downto 0);
    Reg_Flags : out std_logic_vector(15 downto 0);
    Reg_Cmd : out std_logic_vector(15 downto 0);
    Reg_NbParam : out std_logic_vector(15 downto 0);
    Reg_Param : out RF(0 to 63);
    ResetFlagCMD : in std_logic;
    ResetFlagReset : in std_logic;
    

    -- Avalon Master : 
    AM_Address : out std_logic_vector(31 downto 0);
    --AM_ByteEnable : in std_logic;
    AM_Read : out std_logic;
    AM_WaitRequest : in std_logic;
    --AM_Write : out std_logic ; 
    --AM_DataWrite : out std_logic_vector(31 downto 0) ;

    -- Output signals to FIFO
    DataAck : out std_logic ;
    DataTransfer : out std_logic_vector(15 downto 0);
    FIFO_Almost_Full : in std_logic;

    --debug signals
    debug_dma_state : out AcqState;
    debug : out std_logic_vector(15 downto 0);
    debug_write : out std_logic
    );

end AcquModule;

Architecture Comp of AcquModule is 

TYPE AcqState is (Idle, WaitData, WaitFifo, Request, AcqData); 


type reg_array is array (natural range <>) of std_logic_vector(15 downto 0);
signal regs: RF(0 to 70);
signal addr: integer range 0 to 75;

Signal AcqAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal AcqLength: STD_LOGIC_VECTOR(31 downto 0); 

Signal CntAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal CntLength: STD_LOGIC_VECTOR(31 downto 0); 
Signal SM: work.lcd_package.AcqState := Idle; 
signal registers : RF (0 to 70);
signal signal_debug : std_logic := '0';
signal reset_lcd_enable : std_logic := '0';


Begin 

debug_dma_state <= SM;
debug_write <= signal_debug;	

-- Gestion des registres    d'interface 
process (clk, nReset)
    variable temp_regs : RF(0 to 70) := (others => (others => '0'));
    variable written : std_logic := '0';
    variable prev_addr : integer;
Begin     

    if     nReset ='0' THEN
        temp_regs(0) := (others => '0');
        temp_regs(1) := (others => '0');
        temp_regs(2) := (others => '0');
        temp_regs(3) := (others => '0');
        temp_regs(4) := (others => '0');
        temp_regs(5) := (others => '0');
        temp_regs(6) := (others => '0');
        temp_regs(7 to 70) := (others => (others => '0'));
        regs <= temp_regs;
    elsif rising_edge(clk) then
        -- decode address
        temp_regs := regs;

        addr <= to_integer(unsigned(AS_Address));
        -- write operation
        if (AS_Write = '1') then
            signal_debug <= not signal_debug;
            if written = '0' then
                temp_regs(addr) := AS_DataWrite;
                prev_addr := addr;
                written := '1';
            elsif prev_addr /= addr then
                written := '0';
            end if;
        end if;

        if ResetFlagCMD = '0' then
            temp_regs(4)(1) := '0';
        end if;
        if ResetFlagReset = '0' then
            temp_regs(4)(2) := '0';
        end if;   
        if reset_lcd_enable = '0' then
            temp_regs(4)(0) := '0';
        end if;
        
        regs <= temp_regs;

    end if;

end process;

AcqAddress <= regs(0) & regs(1);
AcqLength <= regs(2) & regs(3);
Reg_Flags <= regs(4);
Reg_Cmd <= regs(5);
Reg_NbParam <= regs(6);
Reg_Param <= regs(7 to 70);
debug <= regs(4);

-- Avalon slave read from registers.
PROCESS (clk)
variable tempe_regs : RF(0 to 70) := (others => (others => '0'));
    BEGIN
        
        --IF rising_edge(clk) THEN
            tempe_regs := regs;
            AS_DataRead <= (OTHERS => '0');
            IF AS_Read = '1' THEN
                AS_DataRead <= tempe_regs(to_integer(unsigned(AS_Address)));
            END IF;
        --END IF;
END PROCESS;


-- Acquisition 
pAcquisition: 
Process(clk, nReset) 
Variable Indice : std_logic; 
Begin 

    DataTransfer <= DataAcquisition;  
    DataAck <= NewData;

    if nReset = '0' then 
        --DataAck <= '0'; 
        SM <= Idle; 
        --AM_Write <= '0'; 
        AM_Read <= '0'; 
        AM_Address <= (others => '0');
        CntAddress <= (others => '0'); 
        CntLength <= (others => '0'); 
        DataTransfer <= (others => '0');
    elsif rising_edge(clk) then    
        case SM is 
            when Idle => 
                reset_lcd_enable <= '1';
                if AcqLength /= X"0000_0000" and regs(4)(0) = '1' then 
                    SM <= WaitFifo; 
                    CntAddress <= AcqAddress; 
                    CntLength <= AcqLength; 
                end if; 
            when WaitFifo =>
                if FIFO_Almost_Full = '0' then
                    SM <= Request;
                end if;
            when Request => 
                AM_Read <= '1';
                AM_Address <= x"00000000";
                if AM_WaitRequest = '0' then 
                    SM <= WaitData; 
                end if; 
            when WaitData => 
                AM_Read <= '0';
                AM_Address <= CntAddress; 
                if NewData = '1' then 
                    SM <= AcqData; 
                end if; 
            when AcqData => 
                if to_integer(unsigned(CntLength)) = 0 then
                    reset_lcd_enable <= '0';
                    SM <= Idle;
                    AM_Address <= (others => '0');
                elsif NewData = '1' then 
                    CntAddress <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntAddress)) + 2,CntAddress'length)); 
                    CntLength <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntLength)) - 2,CntLength'length)); 
                    AM_Address <= CntAddress; 
                else
                    SM <= WaitData; 
                end if; 
        end case; 
    end if; 

end process; 


 
End Comp;