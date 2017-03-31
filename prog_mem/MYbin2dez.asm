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

	nop
	nop
	nop
	nop
	
	;initialwert für segen
	ldi R22, 0b00000100		;#4
main:
	eor ZH,ZH			;#5		Z=0x0000
	;GPIOs einlesen
	ldi	ZL, SWH			;#6		Z=0x0033
	ld R11,Z			;#7		R11<-pinc
	ldi	ZL, SWL			;#8		Z=0x0036
	ld R10,Z			;#9		R10<-pinb

	
	rcall delay			;#10
	
	;GPIOs auf LEDs ausgeben
	ldi ZL, LEDH			;#11;portc	
	st Z,R11			;#12
	
	
	ldi ZL, LEDL			;#13;portb
	st Z,R10			;#14
	
	
	;SEG0 schreiben
	mov R17,R10			;#15
	andi R17,0x0F			;#16
	rcall dez2seg			;#17
	ldi ZL, SEG0			;#18
	st Z, R16			;#19
	
	;SEG1 schreiben
	mov R17, R10			;#20
	lsr	R17			;#21
	lsr	R17			;#22
	lsr	R17			;#23
	lsr	R17			;#24
	rcall dez2seg			;#25
	ldi ZL, SEG1			;#26
	st Z, R16			;#27
	
	;SEG2 schreiben
	mov R17,R11			;#28
	andi R17,0x0F			;#29
	rcall dez2seg			;#30
	ldi ZL, SEG2			;#31
	st Z, R16			;#32
	
	;SEG3 schreiben
	mov R17, R11			;#33
	lsr	R17			;#34
	lsr	R17			;#35
	lsr	R17			;#36
	lsr	R17			;#37
	rcall dez2seg			;#38
	ldi ZL, SEG3			;#39
	st Z, R16			;#40
	
	;SEGEN	
	ldi ZL, SEGEN			;#41
	
	cpi R22,0b00010000		;#42
	brne continue			;#43
	ldi R22,0x01			;#44
	continue:
	st	Z, R22			;#45
	lsl R22				;#46
	rcall delay			;#47
	
	rjmp main			;#48


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
	ret					;#91
	eor R18,R18
	loop_delay0:
	
	;eor R19,R19
	;loop_delay1:	
	
	eor R20,R20
	;ldi R20, 0x03		;48Hz -> 50MHz/(4*(255*255*4))
	loop_delay2:
	dec R20
	brne loop_delay2
		
	;dec R19
	;brne loop_delay1
	
	dec R18
	brne loop_delay0	
	ret
