	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

;;; initialization
	eor ZH, ZH		;#4:

boucle:	
	nop			;#5
	ldi ZL, 0x33		;#6: 
	nop			;#7
	ld R16, Z		;#8: R16 <- pinc
	nop			;#9
	ldi ZL, 0x36		;#10: 
	nop			;#11
	ld R17, Z		;#12: R17 <- pinb	
	nop			;#13
	ldi ZL, 0x35		;#14: 
	nop			;#15
	st Z, R16		;#16:portc <- R16
	nop			;#17
	ldi ZL, 0x38		;#18: 
	nop			;#19
	st Z, R17		;#20:portb <- R17
	nop			;#21
	rjmp boucle		;#22:
	
