;-----------------------------------------------------------------------------
;
;
;  FILE NAME   :  lightIntensity.asm
;  TARGET MCU  :  C8051F040
;  DESCRIPTION :  Light intensity detector.
;
; 	NOTES: 
;
;-----------------------------------------------------------------------------

$include (c8051f040.inc)				; Include register definition file.

;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------

		LED1		equ		P3.7
		LED2		equ		P3.5
		LED3		equ		P3.3
		LED4		equ		P3.1
		LED5		equ		P3.0
		LED6		equ		P3.2
		LED7		equ		P3.4
		LED8		equ		P3.6
		LED9		equ		P2.7
		LED10	equ		P2.5

;-----------------------------------------------------------------------------
; RESET and INTERRUPT VECTORS
;-----------------------------------------------------------------------------

				cseg		AT 0x0000		; Reset Vector
				ljmp		main			; Locate a jump to the start of code
									;at the reset vector.
;-----------------------------------------------------------------------------
; MAIN PROGRAM CODE SEGMENT
;-----------------------------------------------------------------------------

mainCodeSeg		segment	CODE

				rseg		mainCodeSeg	; Switch to this code segment.
				using	0			; Specify register bank for the following
									; program code.

main:			call		init			; Initialization of all used SFR's
				mov		SFRPAGE, #ADC2_PAGE		; Use SFRs on the ADC2 Page

start:								; Starting the algorithm				
				call		lightTest		; Tests the intensity of the light
				call		lightLedBar
				jmp		start		; Start over again

;-----------------------------------------------------------------------------
; FUNCTION CODE
;-----------------------------------------------------------------------------

init:			
initWatchDogTimer:	clr		EA			; Disable global interrupts
				mov		WDTCN, #0DEh	; Disable Watch Dog Timer
				mov		WDTCN, #0ADh
				mov		SFRPAGE, #CONFIG_PAGE	; Use SFRs on the
											;configuration Page
initCrossbar:		mov		XBR2, #0x40	; Enable Crossbar

initIOPorts:		anl		P1MDIN, #0xFE	; Configure P1.0 as analog input
				orl		P2MDOUT, #0xA0	; Set all the port pins connected to leds
				orl		P3MDOUT, #0xFF	; as output in push-pull mode
				mov		P2, #0x00		; Route P2 to ground
				mov		P3, #0x00		; Route P3 to ground

initVREF:			mov		SFRPAGE, #0x00	; Use SFRs on the 0x00 Page
				mov		REF0CN, #0x03	; ADC2 voltage reference from internal VREF
									; Enable Bias Generator 

initADC2:			mov		SFRPAGE, #ADC2_PAGE		; Use SFRs on the ADC2 Page
				mov		AMX2CF, #0x00	; Set AIN1.0 as single-ended input
				mov		AMX2SL, #0x00	; Select AIN1.0 as input channel for 
									;the analog multiplexer
				mov		ADC2CF, #0xF9	; Configure a *1 Gain
				mov		ADC2CN, #0x80	; Enable ADC2; Continuos tracking;

				ret


lightTest:		clr		AD2INT		
				setb		AD2BUSY		; Force ADC2 to start a conversion
				jnb		AD2INT, $		; Wait for ADC2 to finish the conversion

				mov		A, ADC2		; Write the converted value in the accumulator
				mov		B, #0x18		; Divides the value by 24.
				div		AB			; [0x00, 0xFF] -> [0x00, 0x0A]
									; the quotient is stored in A
									; the remainder is stored in B
				ret

lightLedBar:		mov		P2, #0x00
				mov		P3, #0x00
				jz		endLight
				setb		LED1
				dec		A
				jz		endLight
				setb		LED2
				dec		A
				jz		endLight
				setb		LED3
				dec		A
				jz		endLight
				setb		LED4
				dec		A
				jz		endLight
				setb		LED5
				dec		A
				jz		endLight
				setb		LED6
				dec		A
				jz		endLight
				setb		LED7
				dec		A
				jz		endLight
				setb		LED8
				dec		A
				jz		endLight
				setb		LED9
				dec		A
				jz		endLight
				setb		LED10
	endLight:		ret

;-----------------------------------------------------------------------------
; End of file.

END