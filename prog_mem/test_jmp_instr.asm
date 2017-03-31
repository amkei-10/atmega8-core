	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP
main:
	ldi	r16,0x04	;#04
brnechk:
	dec 	r16		;#05
	brne	brnechk		;#06

	rcall func		;#07
	
	ldi	r16,0b00100000	;#08
	mov	r2,r16		;#09
brccchk:
	lsl	r2		;#10
	brcc	brccchk		;#11
	rjmp main		;#12
	
func:
	;ret
	eor R18,R18		;#13
	ldi R18, 0x04		;#14
	jmpback:
	dec R18			;#15
	brne jmpback		;#16
	ret			;#17
	
;#00 #01 #02 #03 #04 #05 #06	;R16=0x03
;#05 #06			;R16=0x02
;#05 #06			;R16=0x01
;#05 #06 #07			;R16=0x00
;#13 #14 #15 #16 		;R18=0x03
;#15 #16			;R18=0x02
;#15 #16			;R18=0x01
;#15 #16 #17			;R18=0x00
;#08 #09 #10 #11		;R2=01000000
;#10 #11			;R2=10000000
;#10 #11 #12			;R2=00000000
;#04