# Lab 1 - MSP432 Microcontroller I/O Programming


## Exercice III - Timer to create a delay
### Theory
We need to setup the TimerA to generate an interval timing with the desired milliseconds delay. Compare mode will be used as it allows us to perform specific time intervals. When a compare occurs, the interrupt flag *CCIFG* is set.

- **Clock Source** : The **REFO** sources provides a typical frequency of 32.768 kHz. It becomes a source for the **SMCLK** with the configuration below. It gives a 0.00003051757 second per count, 0.03051757 milliseconds per count
- **Prescaler** : With a prescaler of 8, we get a frequency of 4096Hz, which gives us 0.24414062 milliseconds per tick. Almost a fifth of a milissecond, great. Therefore, five ticks give approximately a milliseconds.
- **Mode** : Up mode, it counts until TAxCCR0 and restarts from zero. With a fifth of a millisecond per tick, if we want say 430ms delay, we would need 430ms*5kHz = 2150 ticks. Therefore CCR0 would be set to this value, and the capture would generate.
- **Output Unit** :
- **Compare Mode** : selected when CAP = 0, if OUTMODx is set to 011 (Set/Reset mode), the output whil be high when the timer reaches TAxCCR1 until TAxCCR0.

In compare mode, any *CCIFG* flag is set if *TAxR* counts to the associated *TAxCCRn* value. Software may also set or clear any *CCIFG* flag. All *CCIFG* flags request an interrupt when their corresponding *CCIE* bit is set.



## Exercice IV - PWM on GPIO with a Timer

### Theory
To generate a PWM, a Timer should be used in which it's **CCR** (Capture Compare Register) is adjusted to fulfill the required PWM duty cycle. Once the timer arrives at the given value, it activates the output, which is connected to the LED we want to blink. Then, when the timer arrives at it's maximum value, it resets and the **OC** (Output Channel) is deactivated. 

### Timer_A module
We'll use the *Timer_A* to generate this PWM output signal. It is a 16bit timer that can increment or decrement. We'll configure it to increment. It's configurations will be the following:

- **Clock Source** : The **REFO** sources provides a typical frequency of 32.768 kHz. It becomes a source for the **SMCLK** with the configuration below.
- **Prescaler** : 
- **Mode** : Up mode, it counts until TAxCCR0 and restarts from zero.
- **Output Unit** :
- **Compare Mode** : selected when CAP = 0, if OUTMODx is set to 011 (Set/Reset mode), the output whil be high when the timer reaches TAxCCR1 until TAxCCR0.

```
    CS->CLKEN |= CS_CLKEN_REFO_EN;                         // enables the REFO clock source


    SELSx   = 2                         // sets the SMCLK clock signal to the REFO clock source
    TAxCTL -> TASSEL  |= 0b10           // clock source set to SMCLK
    TAxCTL -> MC      |= 0b01           // sets the mode to up
    TAxCCR0 |= 0xFFFF                   // sets the maximum count value of the timer
    TAxCCR1 |= 0xF000                   // sets the duty cycle of the PWM
    TAxCCTL0 -> CAP     |= 0b0          // sets to compare mode
    TAxCCTL0 -> OUTMOD  |= 0b011        // sets the Set/Reset mode for the comparison 

```








