	.def ZL = R30
	.def ZH = R31

	main:
	NOP
	NOP
	NOP
	NOP

;;; initialization
	eor 	ZH, 	ZH	;		we_rf			#4
	eor 	R1, 	R1	;		we_rf			#5
	ldi	R16, 	0xBA	;R16=0xBA	we_rf			#6
	ldi	R20, 	0x04	;R20=0x04	we_rf			#7

	ldi	R21, 	0xAA	;R21=0xAA	we_rf			#8
	push 	R21		;DM(1023)=0xAA	we_dm			#9
	push 	R20		;DM(1022)=0x04	we_dm			#10
								
	pop 	R21		;R21=0x04	we_rf			#11
	push 	R20		;DM(1022)=0x04	we_dm			#12
	ldi 	R20, 	0xBB	;R20=0xBB	we_rf			#13
	pop 	R20		;R20=0x04	we_rf			#14
	subi 	R20, 	0x01	;R20=0x03	we_rf			#15
	sub 	R16,	R20	;R16=0xB7	we_rf			#16
	cp 	R16,	R1	;SREG(1)=1				#17
	subi	R16,	0xB7	;R16=0x00	we_rf			#18
	cp 	R16,	R1	;SREG(1)=0				#20
	add 	R20,	R21	;R20=0x07	we_rf			#21
	push 	R16		;DM(1022)=0x00	we_rf			#22
	
	ldi	ZH,	0x03	;					#23
	ldi	ZL,	0xFB	;Z=0x03FB=1019				#24
	st	Z,	R20	;DM(1019)=0x07				#25
	ld	R23,	Z	;R23=0x07				#26
	
	dec	ZL		;Z=0x03FA=1018				#27
	st	Z, ZL		;DM(1018)=1018				#28
	dec	ZL		;					#29
	st	Z, ZL		;DM(1017)=1017				#30
	dec	ZL		;					#31
	st	Z, ZL		;DM(1016)=1016				#32
	dec	ZL		;					#33
	st	Z, ZL		;DM(1015)=1015				#34
	push	ZH		;					#35
	pop	R20		;					#36
rjmp	main