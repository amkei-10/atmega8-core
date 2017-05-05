;Autor: Mario Kellner
;
;Datum: April 2017
;
;Funktionsbeschreibung:
;
; Das Programm liest Pinschalterstellungen aus und wandelt diese in eine Hexadezimaldarstellung auf der  
; 7-Segmentanzeige um. Zusätzlich kann die Ausgabe über die fünf Taster folgendermaßen manipuliert werden:
;
; Taster-HOCH	: Addition 	+1 auf den Ausgabewert
; Taster-RUNTER	: Subtraktion 	-1 auf den Ausgabewert
; Taster-LINKS	: Leftshift 	 1 auf den Ausgabewert
; Taster-RECHTS	: Rightshift 	 1 auf den Ausgabewert
; Taster-Enter	: reset aller Manipulatoren

 	; Adresse von Schalter-GPIO 
	.equ SWH = 0x33 ; SW 15 .. SW 8
	.equ SWL = 0x36 ; SW 7  .. SW 0
	
	; Adresse von LEDs: 
	.equ LEDH = 0x35 ; LED 15 .. LED 8
	.equ LEDL = 0x38 ; LED 7  .. LED 0

 	; 7-Seg-Anzeigen
	.equ SEG0 = 0x41 ; SEG0_N
	.equ SEG1 = 0x42 ; SEG1_N
	.equ SEG2 = 0x43 ; SEG2_N
	.equ SEG3 = 0x44 ; SEG3_N

	; Adresse von Tastern: 
	.equ BTN = 0x30

	; Definition ZL und ZH
	.def ZL = R30
	.def ZH = R31

	.def	EMPTY_R8 = R8
	
	.def	RSHIFT_R15 = R15
	.def	LSHIFT_R14 = R14
	
	.def	ARMANI_L_R10 = R10
	.def	ARMANI_H_R11 = R11
	
	.equ	BITPATTERN_H = 0x00
	.equ	BITPATTERN_L = 0x20
	
	
	nop
	nop
	nop
	nop
	
	eor	EMPTY_R8,EMPTY_R8
	
	rjmp	init_bitpattern
	
	st_bitpattern:
	st	Z, r16
	inc	ZL
	ret
	
	init_bitpattern:
	ldi	ZH, BITPATTERN_H
	ldi	ZL, BITPATTERN_L
		
	ldi	r16, 0b11000000		;0
	rcall	st_bitpattern
	ldi	r16, 0b11111001		;1
	rcall	st_bitpattern
	ldi	r16, 0b10100100		;2
	rcall	st_bitpattern
	ldi	r16, 0b10110000		;3
	rcall	st_bitpattern
	ldi	r16, 0b10011001		;4
	rcall	st_bitpattern
	ldi	r16, 0b10010010		;5
	rcall	st_bitpattern
	ldi	r16, 0b10000010		;6
	rcall	st_bitpattern
	ldi	r16, 0b11111000		;7
	rcall	st_bitpattern
	ldi	r16, 0b10000000		;8
	rcall	st_bitpattern
	ldi	r16, 0b10010000		;9
	rcall	st_bitpattern
	ldi	r16, 0b10001000		;A
	rcall	st_bitpattern
	ldi	r16, 0b10000011		;B
	rcall	st_bitpattern
	ldi	r16, 0b11000110		;C
	rcall	st_bitpattern
	ldi	r16, 0b10100001		;D
	rcall	st_bitpattern
	ldi	r16, 0b10000110		;E
	rcall	st_bitpattern
	ldi	r16, 0b10001110		;F
	rcall	st_bitpattern
	
	rcall 	reset_manipulator
	
	main:
	eor	ZH,ZH			;Z=0x0000		#42
	
	;read GPIOs
	ldi		ZL, SWL	;Z=0x0036
	ld 		R1, Z	;R1<-pinb
	ldi		ZL, SWH	;Z=0x0033
	ld 		R2, Z	;R2<-pinc
	
	ldi		ZL, BTN	;Z=0x0030
	ld		R23, Z	;R3<-pind			#48

	;simple debounce
	dec		R24
	cpi		R24,0xFF
	brne		manipulate_input
	
	;simple edge-detection
	cp		R7,R23
	breq		manipulate_input
	
;+++Set Manipulator+++	
	;ENTER
	cpi		R23, 0b00000001
	brne		check_btnLEFT	
	rcall		reset_manipulator
	
	;LEFT
	check_btnLEFT:
	cpi		R23, 0b00000010
	brne		btnPushed_DOWN
	inc		LSHIFT_R14
	
	;DOWN
	btnPushed_DOWN:
	cpi		R23, 0b00000100
	brne		btnPushed_UP
	inc		EMPTY_R8
	sub		ARMANI_L_R10, EMPTY_R8
	dec		EMPTY_R8
	rol		EMPTY_R8
	sub		ARMANI_H_R11, EMPTY_R8
	eor		EMPTY_R8, EMPTY_R8
	
	;UP
	btnPushed_UP:
	cpi		R23, 0b00001000
	brne		btnPushed_RIGHT
	inc		ARMANI_L_R10
	adc		ARMANI_H_R11, EMPTY_R8
	
	;RIGHT
	btnPushed_RIGHT:
	cpi		R23, 0b00010000
	brne		backup_button
	inc		RSHIFT_R15
;---Set Manipulator---		
 
	backup_button:
 	mov	R7,R23
 	
 	manipulate_input:
 	
 	add	R1, ARMANI_L_R10
 	adc	R2, EMPTY_R8
 	add	R2, ARMANI_H_R11 	
 	
;+++shift+++
 	push	LSHIFT_R14
 	push	RSHIFT_R15
 	cp	LSHIFT_R14, RSHIFT_R15
	brcs	shift_right_init 	
 	
 	;left shift n-times content of R2:R1
 	sub	LSHIFT_R14, RSHIFT_R15
	shift_left:
 	  cp	LSHIFT_R14, EMPTY_R8
 	  breq	manipulation_done
 	  lsl	R2
 	  lsl	R1
 	  adc	R2,EMPTY_R8
 	  dec	LSHIFT_R14
 	  rjmp	shift_left
	
	;right shift R15:R14-times content of R2:R1
	shift_right_init:
 	sub	RSHIFT_R15, LSHIFT_R14
 	shift_right:
 	  cp	RSHIFT_R15, EMPTY_R8
 	  breq	manipulation_done	  
 	  lsr	R1
 	  lsr	R2
 	  
 	  ldi	R17, 0x07
 	  rol	R16
 	  shiftCarry_sevenTimes:
 	  lsl	R16
 	  dec	R17
 	  cpi	R17,0x00
 	  brne	shiftCarry_sevenTimes
 	  
 	  or	R1,R16
 	  dec	RSHIFT_R15
 	  rjmp	shift_right	
	
	manipulation_done:
	
	pop	RSHIFT_R15
 	pop	LSHIFT_R14
;---shift---

	;write GPIOs to the LED-bar
	ldi	ZL, LEDL
	st	Z, R1
	ldi	ZL, LEDH
	st	Z, R2

	;prepair 7-segment-output
	ldi	R18, SEG0
	mov	R16, R1		;r1
	rcall	prep_R16R17	
	rcall	write_sseg

	ldi	R18, SEG1
	mov	R16, R1		;r1
	rcall	shift_r16_fourTimes
	rcall	prep_R16R17
	rcall	write_sseg

	ldi	R18, SEG2
	mov	R16, R2		;r2
	rcall	prep_R16R17
	rcall	write_sseg

	ldi	R18, SEG3
	mov	R16, R2		;r2
	rcall	shift_r16_fourTimes
	rcall	prep_R16R17
	rcall	write_sseg
	
	rjmp main	

	
	reset_manipulator:
	  eor	ARMANI_L_R10,ARMANI_L_R10
	  eor	ARMANI_H_R11,ARMANI_H_R11
	  eor	LSHIFT_R14,LSHIFT_R14
	  eor	RSHIFT_R15,RSHIFT_R15
	ret
	  
	  
	shift_r16_fourTimes:
	  lsr	R16
	  lsr	R16
	  lsr	R16
	  lsr	R16
	ret


	prep_R16R17:
	  ldi	R17, 0x10
	  andi	R16, 0x0F
	ret


	write_sseg:
	  dec	R17
	  cp	R16, R17		
	  brne	write_sseg

	  ldi	ZL, 0x20
	  add	ZL, R17
	  ld	R17, Z		;load binpattern
			  
	  mov	ZL, R18
	  st	Z, R17
	ret
	
	
	
	
