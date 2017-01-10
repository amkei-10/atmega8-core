	;GPIO 
	.equ SWH = 0x33 ; SW 15 .. SW 8
	.equ SWL = 0x36 ; SW 7  .. SW 0

	;LED
	.equ LEDH = 0x35 ; LED 15 .. LED 8
	.equ LEDL = 0x38 ; LED 7  .. LED 0

	;7-Segment
	.equ SEGEN = 0x40
	.equ SEG0 = 0x41
	.equ SEG1 = 0x42
	.equ SEG2 = 0x43
	.equ SEG3 = 0x44
	
	.def ZL = R30
	.def ZH = R31

	;initialwert für segen
	ldi R22, 0b00000100
main:
	eor ZH,ZH
	;GPIOs einlesen
	ldi	ZL, SWH		;pinc
	ld R11,Z
	ldi	ZL, SWL		;pinb
	ld R10,Z

	
	
	;GPIOs auf LEDs ausgeben
	ldi ZL, LEDH	;portc
	st Z,R11
	
	rcall delay
	
	ldi ZL, LEDL	;portb
	st Z,R10
	
	
	;SEG0 schreiben
	mov R17,R10
	andi R17,0x0F
	rcall dez2seg
	ldi ZL, SEG0
	st Z, R16
	
	;SEG1 schreiben
	mov R17, R10
	lsr	R17
	lsr	R17
	lsr	R17
	lsr	R17
	rcall dez2seg
	ldi ZL, SEG1
	st Z, R16
	
	;SEG2 schreiben
	mov R17,R11
	andi R17,0x0F
	rcall dez2seg
	ldi ZL, SEG2
	st Z, R16
	
	;SEG3 schreiben
	mov R17, R11
	lsr	R17
	lsr	R17
	lsr	R17
	lsr	R17
	rcall dez2seg
	ldi ZL, SEG3
	st Z, R16
	
	;SEGEN	
	ldi ZL, SEGEN		
	
	cpi R22,0b00010000	
	brne continue		
	ldi R22,0x01
	continue:
	st	Z, R22			
	lsl R22				
	rcall delay	
	
	rjmp main


; R16:7Seg-Cathode-Pattern, R17:binärwert
dez2seg:
	dez2seg_0: 
		cpi R17, 0
		brne dez2seg_1
		;ldi R16, 0b11000000
		ldi R16, 0b00111111
		ret
	dez2seg_1:
		cpi R17, 1
		brne dez2seg_2
		;ldi R16, 0b11111001
		ldi R16, 0b00000110
		ret
	dez2seg_2:
		cpi R17, 2
		brne dez2seg_3
		;ldi R16, 0b10100100
		ldi R16, 0b01011011
		ret
	dez2seg_3:
		cpi R17, 3
		brne dez2seg_4
		;ldi R16, 0b10110000
		ldi R16, 0b01001111
		ret
	dez2seg_4:
		cpi R17, 4
		brne dez2seg_5
		;ldi R16, 0b10011001
		ldi R16, 0b01100110
		ret
	dez2seg_5:
		cpi R17, 5
		brne dez2seg_6
		;ldi R16, 0b10010010
		ldi R16, 0b01101101
		ret
	dez2seg_6:
		cpi R17, 6
		brne dez2seg_7
		;ldi R16, 0b10000010
		ldi R16, 0b01111101
		ret
	dez2seg_7:
		cpi R17, 7
		brne dez2seg_8
		;ldi R16, 0b11111000
		ldi R16, 0b00000111
		ret
	dez2seg_8:
		cpi R17, 8
		brne dez2seg_9
		;ldi R16, 0b10000000
		ldi R16, 0b01111111
		ret
	dez2seg_9:
		cpi R17, 9
		brne dez2seg_e
		;ldi R16, 0b10010000
		ldi R16, 0b01101111
		ret
	dez2seg_e:
		;ldi R16, 0b00000110
		ldi R16, 0b11111001
ret



delay:
	eor R18,R18
	loop_delay0:
	
	eor R19,R19
	loop_delay1:	
	
	eor R20,R20
	;ldi R20, 0x03		;48Hz -> 50MHz/(4*(255*255*4))
	loop_delay2:
	dec R20
	brne loop_delay2
		
	dec R19
	brne loop_delay1
	
	dec R18
	brne loop_delay0	
	ret
