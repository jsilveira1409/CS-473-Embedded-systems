#include "msp.h"
#include "pwm.h"

void main(void)
{
	WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;		// stop watchdog timer

	lab_setup();
	while(1){

	}
}
