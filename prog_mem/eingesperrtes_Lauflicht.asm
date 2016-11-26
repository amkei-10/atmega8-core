;
; lauflicht workCOREholic.asm
;
; Created: 07.01.2016 21:38:41
; Author : Tobias
;

; Adresse von Schalter-GPIO 
	.equ SWH = 0x33 ; SW 15 .. SW 8
	.equ SWL = 0x36 ; SW 7  .. SW 0

	; Adresse von LEDs: 
	.equ LEDH = 0x35 ; LED 15 .. LED 8
	.equ LEDL = 0x38 ; LED 7  .. LED 0

	; Adresse 7-Segment Anzeige
	.equ SEG_ER = 0x40 ; Segment Enable Register
	.equ SEG0 = 0x41 ; SEG0_N
	.equ SEG1 = 0x42 ; SEG1_N
	.equ SEG2 = 0x43 ; SEG2_N
	.equ SEG3 = 0x44 ; SEG3_N

	; Adresse von Tastern: 
	.equ PB = 0x30

	; Definition ZL und ZH
	.def ZL = R30
	.def ZH = R31
	
	; Switches State
	.def SWITCHES_STATE_LOW = R28
	.def SWITCHES_STATE_HIGH = R29

	; Define Inspected Led
	.def LED_LOW_WRITE_VALUE = R26
	.def LED_HIGH_WRITE_VALUE = R27

	; Fuer Simulation Stack initialisieren --> hoechste Adresse fuer 1kB -10Bit
	ldi R16, 0x03
	out SPH, R16
	ldi R16, 0xFF
	out SPL, R16
			
	; Initialisierung 
	ldi LED_LOW_WRITE_VALUE , 0b000000001   
	ldi LED_HIGH_WRITE_VALUE, 0b000000000
	
main:
	rjmp shift_left
	rjmp shift_right 	
rjmp main

shift_left:
	clc
	rjmp check_for_wall_left
	no_wall_left:
	rcall set_leds
	rcall wait 
	wall_right:
	lsl LED_LOW_WRITE_VALUE	
	brcs shifted_out_left
	lsl LED_HIGH_WRITE_VALUE 	
	brcc repeat_left_shift 
	ldi LED_HIGH_WRITE_VALUE, 0b01000000 
	rjmp shift_right

repeat_left_shift: 
	rjmp shift_left

shifted_out_left:
	ldi LED_HIGH_WRITE_VALUE, 0b00000001 
	rjmp shift_left


check_for_wall_left: 
	rcall load_switches
	and SWITCHES_STATE_LOW, LED_LOW_WRITE_VALUE
	brne wall_left
	and SWITCHES_STATE_HIGH, LED_HIGH_WRITE_VALUE
	brne wall_left	
	rjmp no_wall_left 



shift_right: 
	clc
	rjmp check_for_wall_right
	no_wall_right:
	rcall set_leds
	rcall wait
	wall_left:
	lsr LED_HIGH_WRITE_VALUE
	brcs shifted_out_right; 	
	lsr LED_LOW_WRITE_VALUE
	brcc repeat_right_shift
	ldi LED_LOW_WRITE_VALUE , 0b000000010
	end_shift_right:
	rjmp shift_left
	
repeat_right_shift: 
	rjmp shift_right

shifted_out_right:
	ldi LED_LOW_WRITE_VALUE , 0b10000000
	rjmp shift_right  

check_for_wall_right: 
	rcall load_switches
	and SWITCHES_STATE_LOW, LED_LOW_WRITE_VALUE
	brne wall_right
	and SWITCHES_STATE_HIGH, LED_HIGH_WRITE_VALUE
	brne wall_right	
	rjmp no_wall_right

load_switches:
	ldi ZL, SWL
	ld  SWITCHES_STATE_LOW, Z ; switches low
	ldi ZL, SWH
	ld  SWITCHES_STATE_HIGH, Z ; switches high 
	ret

set_leds:
	ldi ZL, LEDL 
	ST Z, LED_LOW_WRITE_VALUE
	ldi ZL, LEDH
	ST Z, LED_HIGH_WRITE_VALUE
	ret

wait: 
	ldi R17, 0xff 
	loop1:
		ldi R18, 0xff
		loop2:
			ldi R19, 0x0d
			loop3:
				Dec R19
			brne loop3
			Dec R18
		brne loop2
		Dec R17 
	brne loop1 
	ret