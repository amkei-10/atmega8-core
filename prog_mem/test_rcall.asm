	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

main:
	rcall func		;#04
	rjmp main		;#05
	
func:
	eor R18,R18		;#06
	ldi R18, 0x0A		;#07
	jmpback:
	dec R18			;#08
	brne jmpback		;#09
	ret			;#10