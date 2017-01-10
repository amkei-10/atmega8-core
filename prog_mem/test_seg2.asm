	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

	eor ZH, ZH

	ldi ZL, 0x41
	ldi	R16, 0x66
	st	Z, R16

	ldi ZL, 0x42
	ldi	R16, 0x4F
	st	Z, R16
		
	ldi ZL, 0x43
	ldi	R16, 0x5B
	st	Z, R16
	
	ldi ZL, 0x44
	ldi	R16, 0x06
	st	Z, R16
	
	ldi ZL, 0x40		
	ldi	R16, 0x01
	st	Z, R16
	
	ldi ZL, 0x40		
	ldi	R16, 0x02
	st	Z, R16
	
	ldi ZL, 0x40		
	ldi	R16, 0x04
	st	Z, R16
	
	ldi ZL, 0x40		
	ldi	R16, 0x08
	st	Z, R16
	
	push R16
	eor R16, R16
	pop R16


;;; initialization
	eor ZH, ZH

loop:
	ldi ZL, 0x33		; R16 <- pinc
	ld R16, Z

	ldi ZL, 0x36		; R17 <- pinb
	ld R17, Z	

	ldi ZL, 0x35		; portc <- R16
	st Z, R16

	ldi ZL, 0x38		; portb <- R16
	st Z, R17

	rjmp loop
