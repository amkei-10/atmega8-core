	.def ZL = R30
	.def ZH = R31
	
	NOP	;#0
	NOP	;#1
	NOP	;#2
	NOP	;#3

	eor ZH, ZH			;#4

	;Initialisierung der Segment-Register
	ldi 	ZL, 0x38		;#5
	ldi	R16, 0b11110000		;#6
	ldi	R17, 0b00001111		;#7
	st	Z, R16			;#8
	ldi	ZL, 0x35		;#9
	st	Z, R17			;#10
	
	ld	R10, Z
	ldi 	ZL, 0x38		;12
	ld	R11, Z
	
	
	
