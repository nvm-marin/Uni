;-----------------------------------------------------------------------------
;
;
;  FILE NAME   :  serialCommunication.asm
;  TARGET MCU  :  C8051F040
;  DESCRIPTION :  UART1 serial communication program.
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
;-----------------------------------------------------------------------------
; MAIN PROGRAM CODE SEGMENT
;-----------------------------------------------------------------------------

mainCodeSeg		segment	CODE

				rseg		mainCodeSeg	; Switch to this code segment.
				using	0			; Specify register bank for the following
									; program code.

main:			acall	init			; Initialization of all used SFR's
				mov		SFRPAGE, #UART1_PAGE

start:								; Start the algorithm
				call		receiveByte	; Receive a character through UART1
				mov		B, A
				clr		C			; Compare the value in A with #0x41
				subb		A, #0x41		;and jump to error if lower
				jc		error
				mov		A, #0x5A		; Compare the value 0x5A with the value
				subb		A, B			;stored in B and jump to error if lower
				jc		error

				mov		R0, B		; Store in R0 the previously received ASCII code 
				mov		R1, A		; Init the loop counter
				inc		R1
									; Transmit the character with
	loop:		call		sendByte		;the ASCII code stored in R0
				inc		R0			; Increment the ASCII code stored in R0
				djnz		R1, loop		; Decrement R1 and jump to loop if not zero
				sjmp		start		; Start over again

	error:		mov		R0, #0x3F		; Store in R0 the ASCII code of "?"
				mov		R1, #0x03		; Init the loop counter
	errorLoop:	call		sendByte
				djnz		R1, errorLoop	; Decrement R1 and jump if not zero
				sjmp		start		; Start over again

;-----------------------------------------------------------------------------
; FUNCTION CODE
;-----------------------------------------------------------------------------
init:			
				clr		EA			; Disable global interrupts
				mov		WDTCN, #0xDE	; Disable Watch Dog Timer
				mov		WDTCN, #0xAD
				mov		SFRPAGE, #CONFIG_PAGE	; Use SFRs in the
											;configuration Page
				mov		XBR2, #0x44	; Enable the crossbar and UART 1	

initOscillator:	mov       CLKSEL, #0x00
				mov       OSCICN, #0xC3

initTimer1:		mov		SFRPAGE, #TIMER01_PAGE	; Use SFRs in Timer 1 Page
				mov		TMOD, #0x20	; Use Timer 1 in 8-bit auto-reload mode
				mov		TH1, #0x96	; Set the reload value
				mov		CKCON, #0x10	; Timer 1 will use the system clock
				mov		TCON, #0x40	; Enable Timer 1

initUART1:		mov		SFRPAGE, #UART1_PAGE	; Use SFRs in UART 1 Page
				mov		SCON1, #0x10	; Use UART 1 in 8-bit mode

				ret

sendByte:
				mov		SBUF1, R0		; Transmit the byte stored in R0
				jnb		TI1, $		; Wait for the end of transmission
				clr		TI1			; Clear the end of transmission flag
				ret

receiveByte:		jnb		RI1, $		; Wait for the end of reception
				mov		A, SBUF1		; Copy the received data in the accumulator
				clr		RI1			; Clear the end of reception flag
				ret

;-----------------------------------------------------------------------------
; End of file.

END