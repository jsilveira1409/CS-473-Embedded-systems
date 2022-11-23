/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "daisyport.h"
#include <time.h>

void delay(int number_of_seconds)
{
    // Converting time into milli_seconds
    int milli_seconds = 1000 * number_of_seconds;

    // Storing start time
    clock_t start_time = clock();

    // looping till required time is not achieved
    while (clock() < start_time + milli_seconds)
        ;
}


int main()
{
  printf("Hello from Nios II!\n");



  daisy_enable(0);
  daisy_all_set(0, 255, 0);
  daisy_enable(1);
  while(1){
	  daisy_enable(0);
	  daisy_all_set(255, 0, 0);
	  daisy_enable(1);
	  delay(2);
	  daisy_enable(0);
	  daisy_all_set(0, 255, 0);
	  daisy_enable(1);
	  delay(2);
	  daisy_enable(0);
	  daisy_all_set(0, 0, 255);
	  daisy_enable(1);
	  delay(2);
  }
  return 0;
}
