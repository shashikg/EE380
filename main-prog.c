// main-prog.c.

#include<p30f4012.h>
#include "settings-prog.h"
_FOSC(CSW_FSCM_OFF & XT); // To use the external crystal
_FWDT(WDT_OFF);	// To disable the watchdog timer

// split the data by decimal digits (0 - 9)  in 3 digit form
void send_data(int);	

int AD_value();		// Declare the AD value reading function
double pulse;
float V_s, duty, u, error, speed, pos, T;
float Iest[2], West, wf, IV;
float  Fpwm, Kb, Ra, R;
float ac,bc,cc,dc;
float x;
float Is, IF, Ihat;

//
// Declare your variables here
//

void main()
{		
  // Initialise your variables here
 
  wf = 50;       // Filter cut-off frequency in rad/sec
  error = 0.0;
  duty = 0.0; 
  u = 0.0;       // initialise the controller o/p
  speed = 0.0;   // Rad/sec
  pos = 0.0;     // radians
  T = 0.002;     // Sampling time in sec
  Fpwm = 50;     // PWM Frequency in kHz
  V_s = 12.0;    // Power supply Voltage
  TRISD = 0;     // D port is configured as output port
  LATD = 1;      // used for direction control

  qei_set();     // Initialise QEI settings
  pwm_set(Fpwm); // Initialise PWM settings
  uart_set();    // Initialise UART settings
  AD_set();      // Initialise ADC settings
  timer1_set(T); // Initialise Timer-1 settings & start timer
  TRISEbits.TRISE8 = 0; // RE8 is configured as output

  // You need to use your own values of ac, bc, cc, dc below
  ac = 1-0.2*T; bc = T; cc = 0.29898; dc = 0.0151;
  R = 100; Ra = 28.7; Kb = 0.0255;
  // I[0] = 0; I[1] = 0; IF[0] = 0; IF[1] = 0;
  Is = 0; IF = 0; Ihat = 0;

  // Continue until stop the power
  for(;;);
}// End of main()
		
// Interrupt service routine (ISR) for interrupt from Timer1

void __attribute__((interrupt, no_auto_psv)) _T1Interrupt (void)
{
  IFS0bits.T1IF = 0; // Clear timer 1 interrupt flag

  // To calculate the execution time of the controller code make E8 = 1
  
  LATEbits.LATE8 = 1;
  uart_tx(9);

  // QEI count feedback
  // if motor is in anticlockwise direction,count goes down from FFFF.

  if(POSCNT > 0x8000)
  {
    pulse = 0xFFFF - POSCNT;
    pulse = - pulse;
  }
  else
    pulse = POSCNT;
  POSCNT = 0; // Reset the QEI count

  // Calculation of speed (rad/s)
  // speed = 2*pi*( no of pulse/(2*500) )/T in (rad/sec)
  speed = 6.2831853 * pulse/1000/T;
  send_data(speed);  // Transmit the speed

  // send_data(West);

  // Calculation of position (rad)
  // pos_current = pos_past + 2*pi*[no of pulse/(2*500)]/Rg in (rad)
  // Rg = 62 gear ratio
  // pos = pos + 6.2831853 * pulse/62000;
  // send_data(pos*100);  // Transmit the position *100

  // In the experiment where we input a sine wave that lies in the 
  // interval [0,5] V, and the speed reference is a sinusoid, enable
  // the following two lines to give the reference input.
  //
  // R = AD_value(); // In signed mode, ADC maps [0,5] V to [-511,+511].
  // R = 100.0*R/511; // R = 100*sin(w_in*t) rad/sec; 100 is max speed.
  //
  // R = R/511*10.0; // This is a working alternative to R = 10.0*R/511;
  //
      // R = R/511*10 or R = 10*R/511 do not work as we intend. Need
      // to see how C language defines arithmetic operations.
   
  // ---------------------- CAUTION -------------------------------
  // By "amplitude", we mean half the peak-to-peak value,
  // whereas the FG Scientific SM5078 means by "amplitude"
  // the peak-to-peak value of the periodic signal. So, if
  // you wish to apply a sinusoid/triangle/rectangle of
  // peak-to-peak value 5 V (that is, amplitude 2.5 V), set
  // the function generator through MODE --> AMP to 5 V.
  // --------------------------------------------------------------

  // West = (u-Ra*IF)/Kb;
  // West = (u-Ra*Ihat)/Kb;

  // Uncomment below 2 lines in experiments that use feedback of current.
  
  // IV = AD_value();         // Read voltage across Rs=4.7ohm. 
  // IV = 5*(511 + IV)/1022;  // Convert signed to unsigned.

  // Uncomment the following line to observe filtered current
  //
  // send_data(IF*1000);
  //
  // Why the 1000? We have observed in our trials that the current
  // is less than 1 A in magnitude. Irrespective of what the actual
  // values may be, for convenience, we send integers of at most 3
  // digits from the UART module. Therefore, when the current is
  // upto 0.999 in magnitude, we multiply its value by 1000. If we
  // find that it exceeds 0.999, then we may choose to multiply by
  // a number that will result in a product of at most 999.

  //  Ihat = (2.6)*IF; 
  //  Is = IV/4.7;                   // Convert voltage to current.
  //  IF = (1-5.0*T)*IF + 5.0*T*Is;  // Low-pass filter.
  
  /*********** Start of your controller ****************/

  // error = R - West;
  // u = cc*x + dc*error;
  // x = ac*x + bc*error;

  /*-------------- Dead zone compensation-----------------*/
  /*
  if (u > 0)
    u = u + 2;
  else if (u <= 0)
    u = u - 2;
  */
  /*------------End of dead zone compensation-------------*/

  /*********** End of your controller ******************/
  
  // u = 5.0*AD_value()/511;  

  // u=7; // For step input uncomment this  to provide step of 7

  if(u > 0.8 * V_s)
    u = 0.8 * V_s;           // Positive saturation
  else if(u < -0.8 * V_s)
    u = -0.8 * V_s;          // Negative saturation
 
  duty = u/V_s;
  pwm_con(duty);    // Update PWM using new duty ratio
  uart_tx(9);       // Space between 2 pieces of data.
  send_data(u*100); // Send 100 times control effort u.

  LATEbits.LATE8=0;
} // End of ISR of Timer 1


void send_data(int s_data)
{
  int s;
  if(s_data < 0)
  { 
    // Send the negative sign (ASCII is 45)
    uart_tx(45);
    s_data = -1*s_data;
  }
 
  // Digit with the position value of 100
  s = s_data/100;
  uart_tx(s+48);
  
  // Digit with the position value of 10
  s_data = s_data - (s *100);
  s = s_data/10;
  uart_tx(s+48);
  
  // Digit with the position value of 1
  s_data = s_data - (s *10);
  uart_tx(s_data+48);
}// End of send_data()

int AD_value()
{
  int count, *ADC16Ptr, ADCValue = 0;  // clear value
  ADC16Ptr = &ADCBUF0; 	// Initialize ADCBUF pointer
  ADCON1bits.ADON = 1; 	// Turn ADC ON
  IFS0bits.ADIF = 0; 	// Clear ADC interrupt flag
  ADCON1bits.ASAM = 1; 	// Auto start sampling

  while (!IFS0bits.ADIF);  // Conversion done?
  ADCON1bits.ASAM = 0; 	   // If YES then stop sample/convert
  for (count = 0; count < 2; count++) 	// Average the 2 ADC value
    ADCValue = ADCValue + *ADC16Ptr++;

  ADCValue = ADCValue >> 1; // ``>>'' represents ``shift by 1 to left''.
                            // Equivalent to ``divide by 2''.
  return(ADCValue);
}// End of AD_value()
