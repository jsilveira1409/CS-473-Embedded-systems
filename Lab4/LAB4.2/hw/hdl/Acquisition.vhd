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
    DataAcquisition : in std_logic_vector(7 downto 0) ; 
    NewData : in std_logic ; 

    -- Avalon Slave : 
    AS_Address : in std_logic_vector(15 downto 0); 
    AS_CS : in std_logic ; 
    AS_Write : in std_logic ; 
    AS_Read : in std_logic ; 
    AS_DataWrite : in std_logic_vector(15 downto 0) ; 
    AS_DataRead : out std_logic_vector(15 downto 0) ; 

    ResetFlagCMD : in std_logic ;
    ResetFlagReset : in std_logic ;

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
    AM_Write : out std_logic ; 
    AM_DataWrite : out std_logic_vector(31 downto 0) ;

    -- Output signals to FIFO
    DataAck : out std_logic ;
    DataTransfer : out std_logic_vector(15 downto 0);
    FIFO_Almost_Full : in std_logic;

    --debug signals
    debug_dma_state : out AcqState
    );

end AcquModule;

Architecture Comp of AcquModule is 

TYPE AcqState is (Idle, WaitData, WaitFifo, Request, AcqData); 

Signal AcqAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal AcqLength: STD_LOGIC_VECTOR(31 downto 0); 
Signal CntAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal CntLength: STD_LOGIC_VECTOR(31 downto 0); 
Signal SM: work.lcd_package.AcqState; 
signal lcd_enable : std_logic;
signal registers : RF (0 to 70);


Begin 

-- Gestion des registres d'interface 
process(clk, nReset)
    variable tmp : RF(0 to 70);
begin
    if nReset = '0' then
        Reg_ImgAddress <= (others => '0');
        Reg_ImgLength <= (others => '0');
        Reg_Flags <= (others => '0');
        Reg_Cmd <= (others => '0');
        Reg_NbParam <= (others => '0');
        Reg_Param <= (others => (others => '0'));
        tmp := (others => (others => '0'));
    elsif rising_edge(clk) then
        --tmp := registers;
        --registers <= tmp;
        if AS_Write = '1' then
            case to_integer(unsigned(AS_Address)) is
                when 0 to 70 =>
                    registers(to_integer(unsigned(AS_Adddress))) <= AS_DataWrite;
                when others =>
                    null;
                
            end case;
        end if;
        
        AcqAddress <= registers(0) & registers(1);
        AcqLength <= registers(2) & registers(3);
        -- set by cpu
        lcd_enable <= registers(4)(0);
        -- set by lcd controller
        registers(4)(1) <= ResetFlagCMD;
        registers(4)(2) <= ResetFlagReset;

        Reg_ImgAddress <= AcqAddress;
        Reg_ImgLength <= AcqLength;
        Reg_Flags <= registers(4);
        Reg_Cmd <= registers(5);
        Reg_NbParam <= registers(6);
        Reg_Param <= registers(7 to 70);

    end if;
end process;



-- Acquisition 
pAcquisition: 
Process(clk, nReset) 
Variable Indice : std_logic; 
Begin 
    if nReset = '0' then 
        DataAck <= '0'; 
        SM <= Idle; 
        AM_Write <= '0'; 
        AM_Read <= '0'; 
        AM_ByteEnable <= '0'; 
        CntAddress <= (others => '0'); 
        CntLength <= (others => '0'); 
    elsif rising_edge(clk) then 
        debug_dma_state <= SM;
        AM_Read <= '0'; 
        if lcd_enable = '1' then
            case SM is 
                when Idle => 
                    if AcqLength /= X"0000_0000" then 
                        SM <= WaitData; 
                        CntAddress <= AcqAddress; 
                        CntLength <= AcqLength; 
                    end if; 
                when WaitData => 
                    if NewData = '1' then 
                        SM <= WaitFifo; 
                        AM_Address <= CntAddress; 
                        AM_Write <= '1'; 
                        DataTransfer(7 downto 0) <= DataAcquisition;
                        DataTransfer(15 downto 8) <= DataAcquisition;
                        AM_ByteEnable <= '0'; 
                        Indice := CntAddress(0); 
                        AM_ByteEnable <= Indice;
                    --elsif AcqLength = X"0000_0000" then 
                    --    SM <= Idle;
                    end if; 
                when WaitFifo =>
                    if FIFO_Almost_Full = '0' then
                        SM <= Request;
                    end if;
                when Request => 
                    AM_Read <= '1';
                    if AM_WaitRequest = '0' then 
                        SM <= AcqData; 
                        AM_Write <= '0'; 
                        AM_ByteEnable <= '0'; 
                        DataAck <= '1'; 
                    end if; 
                when AcqData => 
                    if to_integer(unsigned(CntLength)) = 0 then
                        SM <= Idle;
                    elsif NewData = '0' then 
                        SM <= WaitData; 
                        DataAck <= '0'; 
                        if to_integer(unsigned(CntLength)) /= 1 then 
                            CntAddress <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntAddress)) + 1,CntAddress'length)); 
                            CntLength <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntLength)) - 1,CntLength'length)); 
                        else 
                            CntAddress <= AcqAddress; 
                            CntLength <= AcqLength; 
                        end if; 
                    end if; 
            end case; 
        end if;
    end if; 
    
End Process pAcquisition; 


 
End Comp;