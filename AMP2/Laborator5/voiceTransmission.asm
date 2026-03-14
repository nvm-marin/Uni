;-----------------------------------------------------------------------------
;
;
;  FILE NAME   :  voiceTransmission.asm
;  TARGET MCU  :  C8051F040
;  DESCRIPTION :  interMicroProcessor voice transmission.
;
; 	NOTES: 
;
;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------

		$include (c8051f040.inc)			; Include register definition file.

;-----------------------------------------------------------------------------
; RESET and INTERRUPT VECTORS
;-----------------------------------------------------------------------------

				cseg		AT 0x0000		; Reset Vector
				ljmp		main			; Locate a jump to the start of code
									;at the reset vector.
				cseg		AT 0x00A3		; UART1 interrupt vector
				ljmp		UART1Irr		; Jump at the interrupt response routine

;-----------------------------------------------------------------------------
; MAIN PROGRAM CODE SEGMENT
;-----------------------------------------------------------------------------


mainCodeSeg		segment	CODE

				rseg		mainCodeSeg	; Switch to this code segment.
				using	0			; Specify register bank for the
									;following program code.

main:			call		init

start:			setb		TI1			; Trigger the first interrupt
				jmp		$			; Wait for interrupts

;-----------------------------------------------------------------------------
; FUNCTION CODE
;-----------------------------------------------------------------------------
init:			
				clr		EA			; Disable global interrupts
				mov		WDTCN, #0xDE	; Disable Watch Dog Timer
				mov		WDTCN, #0xAD

initIOAndCross:	mov		SFRPAGE, #CONFIG_PAGE	; Use SFRs in the
											;configuration Page
				mov		XBR2, #0x44	; Enable the crossbar and UART 1	
    				anl		P1MDIN, #0xFE	; Configure P1.0 as analog input

initOscillator:	mov		CLKSEL, #0x00
				mov		OSCICN, #0xC3	; set SYSCLK to 24.5 MHz
				

initVREF:			mov		SFRPAGE, #0x00	; Use SFRs on the 0x00 Page
				mov		REF0CN, #0x03	; ADC2 voltage reference from internal VREF
									; Enable Bias Generator 
initADC2:			mov		SFRPAGE, #ADC2_PAGE		; Use SFRs in the ADC2 Page
				mov		AMX2CF, #0x00	; Set AIN1.0 as single-ended input
				mov		AMX2SL, #0x00	; Select AIN1.0 as input channel for 
									;the analog multiplexer
				mov		ADC2CF, #0xF9	; Configure a *1 Gain
				mov		ADC2CN, #0x80	; Enable ADC2; Continuos tracking;

initDAC0:			mov 		SFRPAGE, #DAC0_PAGE		; Use SFRs on the DAC0 Page
				mov		DAC0CN, #0x84	; Enable DAC0; a conversion will start only after
				mov		DAC0L, #0x00	;a write in DAC0H; the data format used is 1xx.

initTimer1:		mov		SFRPAGE, #TIMER01_PAGE	; Use SFRs in Timer 1 Page
				mov		TMOD, #0x20	; Use Timer 1 in 8-bit auto-reload mode
				mov		TH1, #0x96	; Set the reload value
				mov		CKCON, #0x10	; Timer 1 will use the system clock
				mov		TCON, #0x40	; Enable Timer 1

initUART1:		mov		SFRPAGE, #UART1_PAGE	; Use SFRs in UART 1 Page
				mov		SCON1, #0x50	; Use UART 1 in 8-bit mode

initInterrupts:	mov		EIE2, #0x40	; Enable and set high priority for 
				mov		EIP2, #0x40	; UART1 transmit/receive interrupt
				setb		EA			; Enable all interrupts

				ret

;-----------------------------------------------------------------------------
; INTERRUPT RESPONSE ROUTINES
;-----------------------------------------------------------------------------

UART1Irr:			push		SFRPAGE		; Save the context (SFRPAGE and ACC)
				push		ACC
				jnb		RI1,	send		; Check the interrupt source:
									;end of transmission or receive
	receive:		mov		SFRPAGE, #UART1_PAGE
				mov		A, SBUF1		; If data received, send it to DAC0
				clr		RI1			; Clear the interrupt flag
				mov		SFRPAGE, #DAC0_PAGE
				mov		DAC0H, A		; Write the data in DAC0H
				jmp		exit

	send:		mov		SFRPAGE, #ADC2_PAGE
				mov		A, ADC2		; If data sent, read another byte
				clr		AD2INT		;from the ADC2
				setb		AD2BUSY		; Force a new conversion
				mov		SFRPAGE, #UART1_PAGE
				clr		TI1			; Clear the interrupt flag
				mov		SBUF1, A		; Sent the read data through the serial
									;connection
	exit:		pop  	ACC
				pop  	SFRPAGE		; Restore the context (SFRPAGE and ACC)
				reti

;-----------------------------------------------------------------------------
; End of file.

END