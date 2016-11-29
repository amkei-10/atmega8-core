	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

;;; initialization
	eor ZH, ZH

boucle:	ldi ZL, 0x33		; R16 <- pinc
	ld R16, Z

	ldi ZL, 0x36		; R17 <- pinb
	ld R17, Z	

	ldi ZL, 0x35		; portc <- R16
	st Z, R16

	ldi ZL, 0x38		; portb <- R16
	st Z, R17

	rjmp boucle
	
