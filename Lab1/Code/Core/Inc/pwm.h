#ifndef PWM_H
#define PWM_H

#include "msp.h"

void pwm_no_timer_gpio(uint8_t duty);
void pwm_timer_setup();
void strobe_effect();
void timed_delay(uint32_t ms_delay);
void timerA_delay(uint32_t ms_delay);
void ex7_setup();
void lab_setup();
#endif
