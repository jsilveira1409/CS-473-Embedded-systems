#include "pwm.h"

/*
 * Exercice 1       DONE
 */
void pwm_no_timer_gpio(uint8_t duty){
    uint32_t cycle = 0xFFFFFFFF;
    uint8_t duty_per = duty;        //percentage 0-100
    uint32_t ccr = cycle*duty_per/100;

    uint32_t i = 0;
    for(i=0; i<cycle; i++){
        if(i <= ccr){
            P2->OUT = (1<<2);  //Sets the bit 0 of the output
        }else{
            P2->OUT = (0<<2);  //Resets the bit 0 of the output
        }
    }
}


/*
 * Exercice 2           DONE
 */
void strobe_effect(){
    uint8_t i = 0;
    const uint8_t nb_leds = 3;
    const uint32_t ticks_to_delay = 50000;

    for(i = 0;i < nb_leds; i++){
        P2->OUT ^= (1<<i);
        //delay(ticks_to_delay);
    }
}

/*
 * Exercice 3           DONE
 */

void ex3_clock_setup(){
    // clock source set to SMCLK
    TIMER_A0->CTL |=  (TIMER_A_CTL_SSEL__SMCLK);
    // sets to compare mode
    TIMER_A0->CTL |=  (0b0 << TIMER_A_CCTLN_CAP_OFS);
    // sets the Set/Reset mode for the comparison
    TIMER_A0->CTL |=  TIMER_A_CCTLN_OUTMOD_3;
    // sets prescaler to 8
    //    TIMER_A0->CTL |=  TIMER_A_CTL_ID__8;
    TIMER_A0->EX0 = TIMER_A_EX0_TAIDEX_7;
}


void timerA_delay(uint32_t ms_delay){
    const uint32_t clk_freq = 32768;                            // Hz
    const uint32_t prescaler = 8;
    uint32_t ticks_to_count = (float)(clk_freq / prescaler) * (float)ms_delay/1000;

    // sets the maximum count value of the timer
    TIMER_A0->CCR[0] = ticks_to_count;
    // sets the mode to up
    TIMER_A0->CTL |=  TIMER_A_CTL_MC__UP;

    while(TIMER_A0->CCTL[0] != TIMER_A_CCTLN_CCIFG){

    }
    // sets the mode to stop
    TIMER_A0->CTL &= ~(1<<TIMER_A_CTL_MC_OFS);
    // resets the counter value
    TIMER_A0->R = 0x0000;
    TIMER_A0->CCTL[0] = 0;
}

/*
 * Exercice 4       NOT DONE
 */

void ex4_clock_setup(uint8_t duty1){
    uint8_t period = 0;
    P2->DIR  |= 0x30;       // P2.4, P2.5 output
    P2->SEL0 |= 0x30;       // P2.4, P2.5 Timer0A functions
    P2->SEL1 &= ~0x30;      // P2.4, P2.5 Timer0A functions
    CS->KEY       =  CS_KEY_VAL;
    // enables the REFO clock source
    CS->CTL1      |=  CS_CTL1_SELS__REFOCLK;
    CS->CLKEN     |=  CS_CLKEN_REFO_EN;

    TIMER_A0->CCR[0] = period;          // Period is 2*period*8*83.33ns is 1.333*period
    TIMER_A0->EX0 = 0x0000;             // divide by 1
    TIMER_A0->CCTL[1] = 0x0040;         // CCR1 toggle/reset
    TIMER_A0->CCR[1] = duty1;           // CCR1 duty cycle is duty1/period
}

/*
 * Exercice 5           DONE
 * Time and prescaler issue
 */
void ex5_setup(uint32_t ms_delay){
    const uint32_t clk_freq = 32768;                            // Hz
    const uint32_t prescaler = 8;
    uint32_t ticks_to_count = (float)(clk_freq / prescaler) * (float)ms_delay/1000;

    CS->KEY       =  CS_KEY_VAL;
    // enables the REFO clock source
    CS->CTL1      |=  CS_CTL1_SELS__REFOCLK;
    CS->CLKEN     |=  CS_CLKEN_REFO_EN;
    // clock source set to SMCLK
    TIMER_A0->CTL |=  (TIMER_A_CTL_SSEL__SMCLK);
    // sets to compare mode
    TIMER_A0->CTL |=  (0b0 << TIMER_A_CCTLN_CAP_OFS);
    // sets the Set/Reset mode for the comparison
    TIMER_A0->CTL |=  TIMER_A_CCTLN_OUTMOD_3;
    // sets prescaler to 8
    TIMER_A0->EX0 = TIMER_A_EX0_TAIDEX_7;
    // sets the maximum count value of the timer
    //TIMER_A0->CCR[0] = ticks_to_count;
    // capture compare interrupt enable
    TIMER_A0->CCTL[0] |= TIMER_A_CCTLN_CCIE;
    // clear pending interrupts
    TIMER_A0->CTL &= ~(1<<TIMER_A_CTL_IFG_OFS);
    // sets the mode to continuous, activate interrupts,
    TIMER_A0->CTL |=  TIMER_A_CTL_MC__CONTINUOUS + TIMER_A_CTL_IE;

    NVIC_EnableIRQ(TA0_0_IRQn);
    NVIC_SetPriority(TA0_0_IRQn,4);

}

//void TA0_0_IRQHandler(void){
//    P2->OUT ^= (1<<0);
//}

/*
 * Exercice 6 DONE
 */

void ex6_setup(){
    // Map P4.0 to A13
    P4->SEL1 |= 0x0001;
    P4->SEL0 |= 0x0001;
    // Select A13 for the INCH of the ADC (already set in differential mode)
    ADC14->MCTL[0] |= ADC14_MCTLN_INCH_13;
    // Enable Conversion
    ADC14->CTL0 |= ADC14_CTL0_ENC + ADC14_CTL0_ON;
    // ADC Value written in ADC14->MEM[0] (?)
}

void ex6_read(){
    // Start Conversion
    ADC14->CTL0 |= ADC14_CTL0_SC;
    // Wait
    uint8_t i=0;
    for(i=0; i <0xFF;i++){}
    // Stop Conversion
    ADC14->CTL0 &= ~(ADC14_CTL0_SC);
}


/*
 * Exercice 7 NOT DONE
 * Lab 1
 */


void ex7_setup(){

//GPIO setup
    P2->DIR   = 0xFF;         // set Port 2 to output direction
    P2->SEL1 &= ~(1<<4);
    P2->SEL0 |= 1<<4;

//Timer A setup
//    CS->KEY       = CS_KEY_VAL;
//    CS->CTL1      = CS_CTL1_SELS__LFXTCLK;
//    CS->CTL2      = CS_CTL2_LFXT_EN;
//    CS->CLKEN     = CS_CLKEN_SMCLK_EN;

    TIMER_A0->CCR[0] = 0x028F;
    TIMER_A0->CCR[1] = 0x0031;
    TIMER_A0->CCTL[0] =  TIMER_A_CCTLN_OUTMOD_7 + TIMER_A_CCTLN_CCIE;
    TIMER_A0->CTL =  TIMER_A_CTL_MC__CONTINUOUS + TIMER_A_CTL_SSEL__SMCLK;

    NVIC_EnableIRQ(TA0_0_IRQn);
    NVIC_SetPriority(TA0_0_IRQn,0);

}

void lab_setup(){
// Normal Timer to start ADC periodically
      /* Enable Interrupts */
      TIMER_A1->CCTL[0] = TIMER_A_CCTLN_CCIE;
      TIMER_A1->EX0 = TIMER_A_EX0_IDEX__8;
      /* use SMCLK, count up, clear TA0R register */
      TIMER_A1->CTL = TIMER_A_CTL_SSEL__SMCLK + TIMER_A_CTL_MC__CONTINUOUS
              + TIMER_A_CTL_CLR + TIMER_A_CTL_IE + TIMER_A_CTL_ID__8;

// PWM TimerA Channel4 setup
    // Output to P2.7
    P2->SEL0 |= 0x80;
    P2->SEL1 &= ~0x80;
    P2->DIR |= 0x80;
    /* PWM Period */
    TIMER_A0->CCR[0] = 0xEB50;
    /* CCR4 PWM duty cycle */
    TIMER_A0->CCR[4] = 0x0BA0;
    /* CCR4 reset/set mode */
    TIMER_A0->CCTL[4] = TIMER_A_CCTLN_OUTMOD_7;
    /* Enable Interrupts */
    TIMER_A0->CCTL[0] = TIMER_A_CCTLN_CCIE;
    /* use SMCLK, count up, clear TA0R register */
    TIMER_A0->CTL = TIMER_A_CTL_SSEL__SMCLK + TIMER_A_CTL_MC__UP
                    + TIMER_A_CTL_CLR + TIMER_A_CTL_IE;

// ADC setup
    // Map P4.0 to A13
    P4->SEL1 |= 0x0001;
    P4->SEL0 |= 0x0001;
    // Enable Conversion
    ADC14->CTL0 =  ADC14_CTL0_SHP | ADC14_CTL0_ON | ADC14_CTL0_SHT0_2;
    ADC14->CTL1 = ADC14_CTL1_RES_3;
    // Select A13 for the INCH of the ADC (already set in differential mode)
    ADC14->MCTL[0] = ADC14_MCTLN_INCH_13;
    ADC14->IER0 |= ADC14_IER0_IE13 + ADC14_IER0_IE0;
    ADC14->CTL0 |= ADC14_CTL0_ENC;

    NVIC_EnableIRQ(ADC14_IRQn);
    NVIC_SetPriority(ADC14_IRQn,2);

    // ADC Value written in ADC14->MEM[0] (?)
    NVIC_EnableIRQ(TA1_0_IRQn);
    NVIC_SetPriority(TA1_0_IRQn,4);

    ADC14->CTL0 |= ADC14_CTL0_SC;
    ADC14->CLRIFGR0 = 0x0;
}

void ADC14_IRQHandler(void){
    uint16_t duty = 0;
    uint16_t val = ADC14->MEM[0];
    duty = val*9000/(16000);
    if (duty <= 6000 && duty >= 3000){
        TIMER_A0->CCR[4] = duty;
    }
    ADC14->CLRIFGR0 = 0x0;
}
void TA1_0_IRQHandler(void){
    // Start Conversion
    ADC14->CTL0 |= ADC14_CTL0_SC;
}


