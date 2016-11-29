	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

	eor ZH, ZH

	ldi ZL, 0x40		
	ldi	R16, 0x01
	st	Z, R16
	
	ldi ZL, 0x41
	ldi	R16, 0x07
	st	Z, R16

