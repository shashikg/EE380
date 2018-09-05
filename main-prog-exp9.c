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
float Is, IF, Ihat;

float x=0.0,u_d=0.5,Kp,Ki,Vr_hat;
int i=0,j,k;

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

  Is = 0; IF = 0; Ihat = 0;

Kp = 0.6; Ki = 10;
  // Continue until stop the power
  for(;;);
}// End of main()
		
// Interrupt service routine (ISR) for interrupt from Timer1

void __attribute__((interrupt, no_auto_psv)) _T1Interrupt (void)
{
  IFS0bits.T1IF = 0; // Clear timer 1 interrupt flag
  // To calculate the execution time of the controller code make E8 = 1 
  LATEbits.LATE8 = 1;

  // QEI count feedback
  // if motor is in anticlockwise direction,count goes down from FFFF.

  if(POSCNT > 0x8000)
  {
    pulse = 0xFFFF - POSCNT;
    pulse = - pulse;
  }
  else    pulse = POSCNT;
  POSCNT = 0; // Reset the QEI count

  // Calculation of speed (rad/s)
  // speed = 2*pi*( no of pulse/(2*500) )/T in (rad/sec)
  speed = 6.2831853 * pulse/1000/T;
    uart_tx(9);
    send_data(u_d*100);  // Transmit the speed

  // Uncomment below 2 lines in experiments that use feedback of current.
  IV = AD_value();         // Read voltage across Rs=4.7ohm. 
  IV = 5*(511 + IV)/1022;  // Convert signed to unsigned.
  
  Is = IV/4.7;                   // Convert voltage to current.
  IF = (1-5.0*T)*IF + 5.0*T*Is;  // Low-pass filter.
  
  /*********** Start of your controller ****************/
  i=i+1;
  u_d = 0.5 + ((double)((int)(i/1000)))/2; // this applies the staircase signal 
  
  Vr_hat = IF*26 + 0.0255*speed;  	// calculation of estimate of motor trminal voltage
  
  error = u_d - Vr_hat;		// these three lines represent a PI controller
  x = x + error*T;
  u = Kp*error + Ki*x;
  /*********** End of your controller ******************/
  
  //u=7; // For step input uncomment this  to provide step of 7

  if(u > 0.8 * V_s)    		u = 0.8 * V_s;           // Positive saturation
  else if(u < -0.8 * V_s)   u = -0.8 * V_s;          // Negative saturation
 
  duty = u/V_s;
  pwm_con(duty);    // Update PWM using new duty ratio
  uart_tx(9); 
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
