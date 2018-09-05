// settings-prog.h: Settings for dsPIC30F4012 PCB with 29.492 MHz
// crystal oscillator


/*------------UART settings:---------------
  Fcy = Fosc/4 = 29492000/4 = 7373000Hz
  U1BRG = {Fcy/(16 * Baud_Rate) } - 1
  conf: 1 stop bit, 8 data bit, no parity
------------------------------------------*/


#include<p30f4012.h>

void timer1_set(float);	// Timer-1 settings
void qei_set();	        // QEI settings 
void pwm_set(int);      // PWM settings
void pwm_con(float);    // PWM control based on duty ratio
void uart_tx(int);      // UART data to be transfered to PC
void uart_set();        // UART settings
void AD_set();          // A-D settings


void pwm_con(float Duty)  // ******* pwm_control function
{  
  int pdc;
  pdc = Duty * 2 *(PTPER + 1);
  if(pdc == 0)
  {
   // Shut down all the IR2110
   LATDbits.LATD1 = 1; 
   LATDbits.LATD0 = 1;	 
  }
  else if(pdc < 0)
  {
   // Make sure IR2110-2 is shut down, and IR2110-1 is active
   LATDbits.LATD1 = 1;	// RD1 = 1, IR2110-2 is shut down
   LATDbits.LATD0 = 0;  // RD0 = 0, IR2110-1 is active
   pdc = 2*( PTPER+1) + pdc;
  }
  else if(pdc > 0)
  {
   // Make sure IR2110-1 is shut down, and IR2110-2 is active
   LATDbits.LATD0 = 1;	// RD0 = 1, IR2110-1 is shut down
   LATDbits.LATD1 = 0;  // RD1 = 0, IR2110-2 is active
  }
  PDC1 = pdc;
}


void timer1_set(float Ts)  // ******* Timer-1 settings
{
  IEC0bits.T1IE = 1;  // Enable Timer-1 interrupt
  IFS0bits.T1IF = 0;  // Clear Timer-1 interrupt flag to get next interrupt
  PR1 = 7373000*Ts;   // No of clk (count) per controller sampling time
  TMR1 = 0;	      // Initialise the Timer count
  T1CON = 0x8000;     // Starts timer, Internal clock (Fosc/4), prescale 1:1
}


void qei_set()  // ******* QEI module settings
{
  ADPCFG = 0x0038;    // Configure pins AN(3-5)/RB(3-5) to Digital I/O mode
                      // AN(0-2) pins are in Analog mode
  IEC2bits.QEIIE = 0; // Disable interrupt due to QEI
  IFS2bits.QEIIF = 0; // Clear the interrupt flag
  QEICON = 0;  	      // Default mode: QEI mode/timer off
  QEICONbits.QEIM= 5;
  DFLTCON = 0x0100;   // No filter operation
  POSCNT = 0;	      // Initialize position of counter
  MAXCNT = 0xFFFF;    // set maxcount limit
}


void pwm_set(int F_pwm)  // ******* PWM module settings
{			
  // PWM timer was enabled, 1:1 prescale Tcy, 1:1 Postscale, 
  PTCON = 0x8000; 	  // PWM time base operates in a free running mode
  PTPER = 7373/F_pwm - 1; // PWM Time Base Period Register (Period of PWM) 
  // Note: PTPER = {Fcy/(Fpwm*PTMER_prescaler) - 1 } 
  // Fcy =Fosc/4 = 7373000
  PWMCON1 = 0x0011;     // PWM I/O pin pair is in complementary output mode
                        // PWM1L & PWM1H enabled; remaining are in I/O mode
  PDC1 = 0;	        // Initially duty ratio is zero;
  OVDCON = 0x0303;      // Controlled by PWM module
  PTMR = 0x0000;        // PWM Time Base Register initialized
}


void uart_tx(int tx_data)  // ******* Transmit the Data through UART 
{
  while(U1STAbits.UTXBF == 1)
  {
   // wait to the UART transmit buffer gets one emty space
  }
  // if(U1STAbits.UTXBF!=1) // If buffer is not full, transmit data
  U1TXREG=tx_data;	// Transmit
}


void uart_set()  // ******* UART module settings
{
  U1MODE = 0x8400;       // 1-stop bit and U1ARX, U1ATX are used
  //U1MODE = 0x8000;     // 1-stop bit and U1RX, U1TX are used
  U1STAbits.UTXEN = 1; 	 // Enable the UART transmiter
  U1STAbits.UTXISEL = 0; // Interrupt generated when any character
                         // transferred to transmit register
  IEC0bits.U1TXIE = 1;   // Enable the Interrupt for the Transmiter
  IFS0bits.U1TXIF = 0;   // Clear transmiter Interrupt flag to transmit
  IEC0bits.U1RXIE = 1;	 // Enable the Interrupt for the Receiver
  IFS0bits.U1RXIF = 0;   // Clear the transmiter Interrupt flag to receive
  U1BRG = 0x0003;        // Baud_rate 115200
  // U1BRG = 0x0007;     // Baud_rate 57600		
}


void AD_set()  // ***** A to D (A/D) Settings
{
  ADPCFG = 0x0038; // Configure pins AN(3-5)/RB(3-5) into Digital 
                   // I/O mode AN(0-2) pins are in Analog mode
  ADCON1 = 0x01E0; // SSRC bit = 111 (auto convert) implies internal
                   // counter ends sampling and starts converting.
  ADCHS = 0x0000;  // Connect RB0/AN0 as CH0 input.  
  ADCSSL = 0;
  ADCON3 = 0x0F00; // Sample time = 15Tad, Tad = internal Tcy/2
  ADCON2 = 0x0004; // Interrupt after every 2 samples
}


// ***** UART Transmit ISR
void __attribute__((interrupt, no_auto_psv)) _U1TXInterrupt(void)
{
  IFS0bits.U1TXIF = 0;  // clear TX interrupt flag
}


// ***** UART Receive ISR
void __attribute__((interrupt, no_auto_psv)) _U1RXInterrupt(void)
{ 
  IFS0bits.U1RXIF = 0; //clear receive interrupt flag
  /*
     while (U1STAbits.URXDA) 
     {
      speedset=U1RXREG;
     } 
  */
  if(U1STAbits.OERR == 1) 
  {
   U1STAbits.OERR = 0; // Clear Overrun Error to receive data 
  }
}  

