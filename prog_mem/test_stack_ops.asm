	.def ZL = R30
	.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

;;; initialization
	eor ZH, ZH
	eor R1, R1
	
	ldi	R20, 0x04
	ldi	R21, 0xAA
	push R21
	push R20
	pop R21
	
m1:
	push R20
	ldi R20, 0xBB
	pop R20
	
	subi R20, 0x01
	cp R20,R1
	brne m1
	rjmp finish
	rjmp end

finish:
	add R20,R21
	ret
	
end:
