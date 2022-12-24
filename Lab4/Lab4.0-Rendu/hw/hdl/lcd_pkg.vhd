library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lcd_package is

	type RF is array (natural range <>) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	TYPE LCDFSM IS (IDLE, RESET, RESET_REGS, CMD_READ, IMG_DISPLAY, PARAM_GET, CMD_SEND, PIXEL_WRITE, PIXEL_GET);
	TYPE AcqState is (Idle, WaitData, WaitFifo, Request, AcqData); 

end package;
    