	.def ZL = R30
	.def ZH = R31
	
	NOP	;#0
	NOP	;#1
	NOP	;#2
	NOP	;#3

	eor ZH, ZH			;#4

	;Initialisierung der Segment-Register
	ldi ZL, 0x41		;#5:s0
	ldi	R16, 0b11111001	;#6:0x06 = "1"
	st	Z, R16			;#7
	
	inc ZL				;#8:s1
	ldi	R16, 0b10100100	;#9: 0x5B= "2"
	st	Z, R16			;#10
	
	inc ZL				;#11:s2
	ldi	R16, 0b10110000	;#12: 0x4F = "3"
	st	Z, R16			;#13
	
	inc ZL				;#14:s3
	ldi	R16, 0b10011001	;#15:0xE6 = "4"
	st	Z, R16			;#16
	
	ldi R16, 0b00000100	;#17
	ldi ZL, 0x40		;#18
	
loop:
	cpi R16,0b00010000	;#19
	brne continue		;#20
	rcall reset			;#21
	continue:
	st	Z, R16			;#22
	lsl R16				;#23
	rcall delay
	rjmp loop			;#24
	

reset:
	ldi R16,0x01		;#25:R16=0x01
	st Z, R16			;#26:io(
	ret					;#27


delay:
	eor R17,R17	
	loop_delay0:
	
	eor R18,R18
	loop_delay1:	
	
	eor R19,R19
	loop_delay3:
	
	dec R19
	brne loop_delay3
		
	dec R18
	brne loop_delay1
	
	dec R17
	brne loop_delay0	
	ret
	
	
	
	
