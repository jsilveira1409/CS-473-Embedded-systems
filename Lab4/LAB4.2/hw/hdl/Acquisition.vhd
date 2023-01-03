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
    --AS_CS : in std_logic ; 
    AS_Write : in std_logic ; 
    AS_Read : in std_logic ; 
    AS_DataWrite : in std_logic_vector(31 downto 0) ; 
    AS_DataRead : out std_logic_vector(31 downto 0) ; 

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
    --AM_ByteEnable : out std_logic;
    AM_ByteEnable : in std_logic;
    AM_Read : out std_logic;
    AM_WaitRequest : in std_logic;
    AM_Write : out std_logic ; 
    AM_DataWrite : out std_logic_vector(31 downto 0) ;

    -- Output signals to FIFO
    DataAck : out std_logic ;
    DataTransfer : out std_logic_vector(15 downto 0);
    FIFO_Almost_Full : in std_logic;

    --debug signals
    debug_dma_state : out AcqState;
    debug : out std_logic
    );

end AcquModule;

Architecture Comp of AcquModule is 

TYPE AcqState is (Idle, WaitData, WaitFifo, Request, AcqData); 

Signal AcqAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal AcqLength: STD_LOGIC_VECTOR(31 downto 0); 
signal signal_reg_cmd : std_logic_vector(15 downto 0);
signal signal_reg_nb_param : std_logic_vector(15 downto 0);
Signal CntAddress: STD_LOGIC_VECTOR(31 downto 0); 
Signal CntLength: STD_LOGIC_VECTOR(31 downto 0); 
Signal SM: work.lcd_package.AcqState; 
signal lcd_enable : std_logic;
signal registers : RF (0 to 70);
signal flag : std_logic_vector(15 downto 0);
signal signal_debug : std_logic := '1';


Begin 

-- Gestion des registres d'interface 
process(clk, nReset)
    variable tmp : RF(0 to 70);
begin
    if nReset ='1' then
        tmp := (others => (others => '0'));
        Reg_ImgAddress <= (others => '0');
        Reg_ImgLength <= (others => '0');
        Reg_Flags <= (others => '0');
        Reg_Cmd <= (others => '0');
        Reg_NbParam <= (others => '0');
        Reg_Param <= (others => (others => '0'));
        
    elsif rising_edge(clk) then
        --if AS_CS = '1' then
            
            if AS_Write = '1' then
                -- invert debug signal
                --signal_debug <= not signal_debug;
                if AS_Address = x"0000" then                                       -- img address
                    AcqAddress <= AS_DataWrite;
                elsif AS_Address = x"0004" then                                    -- img length
                    AcqLength <= AS_DataWrite;
                elsif AS_Address = x"0008" then                                    -- flags
                    flag <= AS_DataWrite(15 downto 0);
                elsif AS_Address = x"000A" then                                    -- cmd  
                    signal_reg_cmd <= AS_DataWrite(15 downto 0);               
                elsif AS_Address = x"000C" then                                    -- nb param
                    signal_reg_nb_param <= AS_DataWrite(15 downto 0);
                elsif AS_Address >= x"000E" and AS_Address <= X"0043" then    -- params
                    Reg_Param(to_integer(unsigned(AS_Address(8 downto 2)))) <= AS_DataWrite;
                end if;
            elsif AS_Read = '1' then
                --signal_debug <= not signal_debug;
                if AS_Address = x"0000" then                                       -- img address
                    AS_DataRead <= AcqAddress;
                elsif AS_Address = x"0004" then                                    -- img length
                    AS_DataRead <= AcqLength;
                elsif AS_Address = x"0008" then                                    -- flags
                    AS_DataRead(15 downto 0) <= flag ;
                elsif AS_Address = x"000A" then                                    -- cmd
                    AS_DataRead(15 downto 0) <= signal_reg_cmd;
                elsif AS_Address = x"000C" then                                    -- nb param
                    AS_DataRead(15 downto 0) <= signal_reg_nb_param;
                end if;    
            end if;
             
            
            Reg_ImgAddress <= AcqAddress;
            Reg_ImgLength <= AcqLength;
            Reg_Cmd <= signal_reg_cmd;
            Reg_NbParam <= signal_reg_nb_param;
            Reg_Flags <= flag;
            lcd_enable <= flag(0);
            

            if ResetFlagCMD = '0' then
                Reg_Cmd <= (others => '0');
                flag(1) <= '0';
            end if;
            if ResetFlagReset = '0' then
                flag(2) <= '0';
            end if;
        end if;
        
    --end if;
end process;




-- Acquisition 
pAcquisition: 
Process(clk, nReset) 
Variable Indice : std_logic; 
Begin 

    DataTransfer <= DataAcquisition;  
    DataAck <= NewData;

    if nReset = '1' then 
        --DataAck <= '0'; 
        SM <= Idle; 
        AM_Write <= '0'; 
        AM_Read <= '0'; 
        AM_Address <= (others => '0');
        --AM_ByteEnable <= '0'; 
        CntAddress <= (others => '0'); 
        CntLength <= (others => '0'); 
        DataTransfer <= (others => '0');
        debug <= '0';
    elsif rising_edge(clk) then 
        debug_dma_state <= SM;
        AM_Read <= '0'; 
        debug <= signal_debug;    
        if lcd_enable = '1' then
            signal_debug <= not signal_debug;
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
                        --AM_DataWrite(15 downto 8) <= DataAcquisition;
                        --AM_DataWrite(7 downto 0) <= DataAcquisition(7 downto 0);                
                        --DataTransfer(7 downto 0) <= DataAcquisition;
                        --DataTransfer(15 downto 8) <= DataAcquisition;
                        --AM_ByteEnable <= '0'; 
  --                      Indice := CntAddress(0); 
--                        AM_ByteEnable <= Indice;
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
                        --AM_ByteEnable <= '0'; 
                        --DataAck <= '1'; 
                    end if; 
                when AcqData => 
                    if to_integer(unsigned(CntLength)) = 0 then
                        SM <= Idle;
                        AM_Address <= (others => '0');
                    elsif NewData = '1' then 
                        SM <= WaitData; 
                        --DataAck <= '0'; 
                        CntAddress <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntAddress)) + 2,CntAddress'length)); 
                        CntLength <=  std_logic_vector(to_unsigned(to_integer(unsigned(CntLength)) - 2,CntLength'length)); 
                    end if; 
            end case; 
        end if;
    end if; 

end process; 


 
End Comp;