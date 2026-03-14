;-----------------------------------------------------------------------------
;
;
;  FILE NAME   :  blinky.asm
;  TARGET MCU  :  C8051F040
;  DESCRIPTION :  LED blinking.
;
; 	NOTES: 
;
;-----------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------

		$include (c8051f040.inc)			; Include register definition file.

		GREEN	equ   P1.6			; Label port P1.6 as GREEN (green led)

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
				using	0			; Specify register bank for the
									;following program code.

main:			acall	init
	mainLoop:		mov 		A, #0x02
				call		delay
				cpl		GREEN
               	jmp		mainLoop

;-----------------------------------------------------------------------------
; FUNCTION CODE
;-----------------------------------------------------------------------------

delay:			mov   	R7, A
	loop1:		mov   	R6, #0x00
	loop0:		mov   	R5, #0x00
		     	djnz  	R5, $
               	djnz  	R6, loop0
               	djnz  	R7, loop1
				ret

init:			
				clr		EA			; Disable global interrupts
				mov		WDTCN, #0xDE	; Disable Watch Dog Timer
				mov		WDTCN, #0xAD
				mov		SFRPAGE, #CONFIG_PAGE	; Use SFRs in the
											;configuration Page
initIOandCross:	mov		XBR2, #0x40	; Enable Crossbar
				orl		P1MDOUT, #0x40	; Set P1.6 (GREEN) as digital
									;output in push-pull mode.
				clr		GREEN		; Turn off green led

				ret
;-----------------------------------------------------------------------------
; End of file.

END

