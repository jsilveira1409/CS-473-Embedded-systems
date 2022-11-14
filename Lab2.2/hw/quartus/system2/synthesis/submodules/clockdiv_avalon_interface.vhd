LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clockdiv_avalon_interface IS
	PORT ( 	
				clock, resetn		:	IN 	STD_LOGIC;
				enable_out			:	OUT	STD_LOGIC
			);
END clockdiv_avalon_interface;


ARCHITECTURE Structure OF clockdiv_avalon_interface IS
		
	COMPONENT clockdiv
		PORT ( 	
					clock, resetn 	: 	IN 	STD_LOGIC;
					enable_out		:	OUT	STD_LOGIC
				);
	END COMPONENT;

	BEGIN
				
END Structure;