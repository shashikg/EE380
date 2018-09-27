// main-prog.c.

#include<p30f4012.h>
#include "settings-prog.h"
_FOSC(CSW_FSCM_OFF & XT); // To use the external crystal
_FWDT(WDT_OFF);	// To disable the watchdog timer

// split the data by decimal digits (0 - 9)  in 3 digit form
void send_data(int);	

int AD_value();		// Declare the AD value reading function
double pulse;
float V_s, duty, u, speed, pos,T,R, Iest[2], West, I[2], IF[2], wcf, error;
float  Fpwm, Kb, Ra, uw, xw, we, B, J, tau, IV, Iref, Ihat, y1, y2, ILhat, xim;
float Kt, xiw, xu, Ie,TL_hat, wf[2], wcfw, speed0;
//
// Declare your variables here
//
// ****** Main Program

void main()
{		
  // Initialise your variables here
  xw = 0;
  xim = 0;
  xiw = 0;
  xu = 0;

  B = 0.0000029374;
  J = 0.0000013;
  tau = 0.5;
  Kt = 0.0255;
  wcf = 25;    // Current filter cut-off frequency in rad/sec
  wcfw = 100;   // Speed filter cut-off frequency in rad/sec 
  error = 0;  
  I[0] = 0;   // Initial past current
  IF[0] = 0;  // Initial past filtered current
  speed0 = 0;
  wf[0] = 0;
  duty = 0.0; 
  u = 0;      // initialise the controller o/p
  speed =0.0; // Rad/sec
  pos = 0.0;  // radians
  T = 0.002;  // Sampling time in sec
  Fpwm = 50;  // PWM Frequency in kHz
  V_s = 15.0; // Power supply Voltage
  TRISD = 0;  // D port is configured as output port
  LATD = 1;   // used for direction control
  qei_set();  // Initialise QEI settings
  pwm_set(Fpwm); // Initialise PWM settings
  uart_set();    // Initialise UART settings
  AD_set();      //Initialise ADC settings
  timer1_set(T); // Initialise Timer-1 settings and starts the timer
  TRISEbits.TRISE8 = 0; // RE8 is configured as output

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

  // Calculation of position (rad)
  // pos_current = pos_past + 2*pi*( no of pulse/(2*500) )/Rg in (rad)
  // Rg = 62 gear ratio
  // pos = pos + 6.2831853 * pulse/62000;
  // send_data(pos*100);  // Transmit the position *100

  // In the experiment where we input a sine wave that lies in the 
  // interval [0,5] V, and the speed reference is a sinusoid, enable
  // the following two lines to give the reference input.
  // R = AD_value(); // In signed mode, ADC maps [0,5] V to [-511,+511].
  // R = 150*R/511;  // R = 150*sin(w_in*t) rad/sec; 150 is max speed.

  // Uncomment following lines in experiments where current feedback used.
  ///*
    IV = AD_value();  // Read voltage across Rs=4.7ohm. 
    IV = 5*(511 + IV)/1022; // Convert signed to unsigned.
    I[1] = IV/4.7; // Convert voltage to current.
				   // I denotes Isense.


    // Low-pass filter with cut-off frequency wf:
    IF[1] = (wcf*T/(2+wcf*T))*(I[1]+I[0])+((2-wcf*T)/(2+wcf*T))*IF[0];
    // Prepare IF[0] and I[0] for the next sampling interval
    IF[0] = IF[1];
    I[0] = I[1]; 
   // */

  // IF[1] denotes the filtered version of I
  // Only if you want to observe filtered current, uncomment following line
  //
  // send_data(IF[1]*1000);
  //
  // Why the 1000? We have observed in our trials that the current is 
  // less than 1 A in magnitude. Irrespective of what the actual values
  // may be, for convenience, we send integers of at most 3 digits from
  // the UART module. Therefore, when the current is upto 0.999 in
  // magnitude, we multiply its value by 1000. If we find that it exceeds
  // 0.999, then we may choose to multiply by a number that will result
  // in a product of at most 999.
	
  /*************************************/
  /****  Your controller code      *****/
  /***** goes in place of this box *****/
  /*************************************/

  // Speed controller
  we = 100-speed;
  //we = 100-wf[1];
  Iref = 0.001157*(we + (19.1876-0.02218)*xw);
  xw = we*T+(1-0.02218*T)*xw;

  // pole at current path

  Ihat = IF[1]/1.25 - 1/1000;
  y1 = xim/tau;
  xim = Ihat*T + (1-T/tau)*xim;

  // estimation of I from speed
  y2 = (J/Kt/tau)*(speed + (B/J - 1/tau)*xiw);
  xiw = speed*T +(1-T/tau)*xiw;

  // estimation of load current
  ILhat = y1 - y2;

  // Ie = Iref + ILhat - y1; // with IL_hat fed back
  Ie = Iref  - y1; // without feedback of IL_hat

  // current controller
  u = 250*Ie + 100*xu;
  xu = Ie*T + xu;

  // u=7; // Uncommment this line to provide step of 7
  if(u > 0.8 * V_s)
    u = 0.8 * V_s;  // Positive saturation
  else if(u < -0.8 * V_s)
    u = -0.8 * V_s; // Negative saturation
 
  duty = u/V_s;
  pwm_con(duty);    // Update the PWM with respect ot the new duty ratio

  uart_tx(9); 
  //send_data(u*10); // Sending 100 times control effort u.

  // Estimating & sending load torque
  TL_hat = ILhat*Kt;
  send_data(TL_hat*100000);

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
