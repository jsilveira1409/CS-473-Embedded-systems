LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.lcd_package.all;


entity acq_controller is
    port(
    clk : in std_logic;
    nReset : in std_logic;

 -- Acquisition 
    DataAcquisition : in std_logic_vector(7 downto 0) ; 
    NewData : in std_logic := '0'; 
    --ImageDone : in std_logic;  devrait etre un signal interne je pense

-- Avalon Slave : 
    AS_Address : in std_logic; 
    AS_CS : in std_logic ; 
    AS_Write : in std_logic ; 
    AS_Read : in std_logic ; 
    AS_DataWrite : in std_logic_vector(31 downto 0) ; 
    AS_DataRead : out std_logic_vector(31 downto 0) ; 
	 AS_reset_flag_cmd : in std_logic;
	 AS_reset_flag_enable : in std_logic;
    AS_reset_flag_reset : in std_logic

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
--    DataAck : out std_logic ;
   );

end acq_controller;

Architecture Comp of acq_controller is 


Architecture Comp of AcquModule is 

    TYPE AcqState is (Idle, WaitData, WaitFifo, Request, AcqData); 
    Signal AcqAddress: STD_LOGIC_VECTOR(31 downto 0); 
    Signal AcqLength: STD_LOGIC_VECTOR(31 downto 0); 
    Signal CntAddress: STD_LOGIC_VECTOR(31 downto 0); 
    Signal CntLength: STD_LOGIC_VECTOR(31 downto 0); 
    Signal SM: AcqState; 

    Begin 
    -- Gestion des registres d'interface 
    pAvalon_Slave: Process(clk, nReset) 
    Begin 
        if nReset = '0' then 
            AcqAddress <= (others => '0'); 
            AcqLength <= (others => '0'); 
        elsif rising_edge(clk) then 
            if AS_CS = '1' then 
                if AS_Write = '1' then 
                    case AS_Address is 
                        when '0' => AcqAddress <= AS_DataWrite; 
                        when '1' => AcqLength <= AS_DataWrite; 
                        when others => null; 
                    end case; 
                elsif AS_Read = '1' then 
                    case AS_Address is 
                        when '0' => AS_DataRead <= AcqAddress; 
                        when '1' => AS_DataRead <= AcqLength; 
                        when others => null; 
                    end case; 
                end if; 
            end if; 
        end if; 
    End Process pAvalon_Slave;


    -- Acquisition 
    pAcquisition: 
    Process(clk, nReset) 
    
	 Variable Indice : Integer Range 0 to 3; 
	 
    Begin 
        if nReset = '0' then 
            SM <= Idle; 
            AM_Read <= '0'; 
				DataSend <= '0';
            AM_ByteEnable <= "0000"; 
            CntAddress <= (others => '0'); 
            CntLength <= (others => '0'); 
				
        elsif rising_edge(clk) then 
            AM_Read <= '0'; 
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
                        DataSend <= '1'; 
                        DataTransfer(7 downto 0) <= DataAcquisition;
                        DataTransfer(15 downto 8) <= DataAcquisition;
                        DataTransfer(23 downto 16) <= DataAcquisition;
                        DataTransfer(31 downto 24) <= DataAcquisition;
                        AM_ByteEnable <= "0000"; 
                        Indice := to_integer(unsigned(CntAddress(1 downto 0))); 
                        AM_ByteEnable(Indice) <= '1'; 
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
                        DataSend <= '0'; 
                        AM_ByteEnable <= "0000"; 
    --                    DataAck <= '1'; 
                    end if; 
                when AcqData => 
                    if ImageDone = '1' then
                        SM <= Idle;
                    elsif NewData = '0' then 
                        SM <= WaitData; 
    --                    DataAck <= '0'; 
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
    End Process pAcquisition; 
 
End Comp;