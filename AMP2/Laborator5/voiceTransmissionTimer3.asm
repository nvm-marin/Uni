;-----------------------------------------------------------------------------
;
;
;  FILE NAME   :  voiceTransmissionTimer3.asm
;  TARGET MCU  :  C8051F040
;  DESCRIPTION :  Data transfer from ADC2 to DAC0 at a given frequency.
;
; 	NOTES: 
;
;-----------------------------------------------------------------------------

$include (c8051f040.inc)				; Include register definition file.

;-----------------------------------------------------------------------------
; RESET and INTERRUPT VECTORS
;-----------------------------------------------------------------------------

				cseg		AT 0x0000		; Reset Vector
				ljmp		main			; Locate a jump to the start of code
									;at the reset vector.

				cseg		AT 0x0073
				ljmp		Timer3Irr	
;-----------------------------------------------------------------------------
; MAIN PROGRAM CODE SEGMENT
;-----------------------------------------------------------------------------

mainCodeSeg		segment	CODE

				rseg		mainCodeSeg	; Switch to this code segment.
				using	0			; Specify register bank for the following
									; program code.

main:			acall	init			; Initialization of all used SFR's
			;	mov		SFRPAGE, #TMR3_PAGE		; Use SFRs on the Timer3 Page
			;	jnb		TF3, $		; Waiting for a Timer3 overflow.
			;	clr		TF3			; Reset the overflow flag.
				jmp		$


Timer3Irr:
				push		SFRPAGE		; Save the context (SFRPAGE and ACC)
				push		ACC
			
				mov		SFRPAGE, #ADC2_PAGE		; Use SFRs on the ADC2 Page
				clr		AD2INT		; Reset AD2INT.
				mov		A, ADC2		; Write the converted value in the accumulator

				mov		SFRPAGE, #DAC0_PAGE		; Use SFRs on the DAC0 Page
				mov		DAC0H, A		; Write the value from the accumulator
									;in upper byte of DAC0
	exit:		pop  	ACC
				pop  	SFRPAGE	
				reti
;-----------------------------------------------------------------------------
; FUNCTION CODE
;-----------------------------------------------------------------------------
    	
init:
				clr		EA			; Disable global interrupts
				mov		WDTCN, #0DEh	; Disable Watch Dog Timer
				mov		WDTCN, #0ADh
initIOandCross:	mov		SFRPAGE, #CONFIG_PAGE	; Use SFRs on the configuration Page

				mov		XBR2, #0x40	; Enable Crossbar
				mov		P1MDIN, #0xFE	; Configure P1.0 as analog input
				mov		P1MDOUT, #0x00	; For analog data the port must be set as open-drain.

initVREF:			mov		SFRPAGE, #0x00	; Use SFRs on the 0x00 Page
				mov		REF0CN, #0x03	; ADC2 voltage reference from internal VREF
									; Enable Bias Generator 

initDAC0:			mov		DAC0CN, #0x84	; Enable DAC0; a conversion will start only after
				mov		DAC0L, #0x00	;a write in DAC0H; the data format used is 1xx.

initADC2:			mov		SFRPAGE, #ADC2_PAGE		; Use SFRs on the ADC2 Page
				mov		AMX2CF, #0x00	; Set AIN1.0 as single-ended input
				mov		AMX2SL, #0x00	; Select AIN1.0 as input channel for 
									;the analog multiplexer
				mov		ADC2CF, #0x01	; Configure a *1 Gain
				mov		ADC2CN, #0x82	; Enable ADC2; Continuos tracking;

initTimer3:    	mov		SFRPAGE, #TMR3_PAGE	; Use SFRs on the Timer3 Page
				mov		TMR3CF, #0x08	; Counting frequency is the SYSCLK frequency
				mov		RCAP3H, #0xFF	; Set the reload value
				mov		RCAP3L, #0x44	; The reload value triggers a
				mov		TMR3H, #0xFF	;sampling frequency of 16kHz. Please see the formula!
				mov		TMR3L, #0x44
				mov		TMR3CN, #0x04	; Enable Timer3.

enableTimerIrr:	mov		EIE2, #0x01			
				mov		EIP2, #0x01
				setb		EA

				ret

;-----------------------------------------------------------------------------
; End of file.

END