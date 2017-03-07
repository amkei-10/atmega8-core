; Adress-Deklarationen
	
	; Adresse von Schalter-GPIO 
	.equ SWH = 0x33 ; SW 15 .. SW 8
	.equ SWL = 0x36 ; SW 7  .. SW 0

	; Adresse von LEDs: 
	.equ LEDH = 0x35 ; LED 15 .. LED 8
	.equ LEDL = 0x38 ; LED 7  .. LED 0

	; Adresse 7-Segment Anzeige
	.equ SEG_ER = 0x40 ; Segment Enable Register
	.equ SEG0 = 0x41 ; SEG0_N
	.equ SEG1 = 0x42 ; SEG1_N
	.equ SEG2 = 0x43 ; SEG2_N
	.equ SEG3 = 0x44 ; SEG3_N

	; Adresse von Tastern: 
	.equ PB = 0x30

	; Definition ZL und ZH
	.def ZL = R30
	.def ZH = R31

	;-- NOP, EOR, LDI
	nop			;#0:
	nop			;#1:
	nop			;#2:
	nop			;#3:	
	
	eor R16,R16		;#4:
	eor R17,R17		;#5:
	ldi R17, 0x0A		;#6:R17=0x0A
	
	;-- INC, DEC, PUSH, POP
	inc R16			;#7:R16=0x01
	dec R16			;#8:R16=0x00	
	push R17		;#9:
	pop R16			;#10:R16=0x0A
	
	;-- ADD, SUB, SUBI, CP, LSL, MOV, ANDI, ROL, ADC
	add R16,R17		;#11:R16=0x14
	sub R16,R17		;#12:R16=0x0A
	subi R16, 0x0A		;#13:R16=0x00

	ldi R16,0x05		;#14:R16=0x05
	cp	R16,R17		;#15:
	lsl	R16		;#16:R16=0x0A
	cp	R16,R17		;#17:
	
	ldi R16,0xff		;#18:R16=0xff
	mov R17, R16		;#19:R17=0xff
	andi R16,0x80		;#20:R16=0x80 		C=0
	rol R16			;#21:R16=0x00		C=1
	adc R17,R16		;#22:R17=0x00

	;-- ST, LD, AND
	ldi R16,0xff		;#23:R16=0xff
	ldi R17,0x08		;#24:R17=0x08
	ldi ZL,0x04		;#25:R30=04
	ldi ZH,0x01		;#26:R31=01
	st	Z,R17		;#27:data_mem(260)=0x08
	inc ZL			;#28:R30=05
	st	Z,R16		;#29:data_mem(261)=0xff
	and R16, R17		;#30:R16=0x08
	ld 	R16,Z		;#31:R16=0xff
	
	;-- COM, ASR, LSR, CPI
	com R17			;#32:R17=-9=0xF7
	asr R17			;#33:R17=-5=0xFB	C=1
	lsr R17			;#34:R17=125=0x7D 	C=1
	cpi R17,0x7F		;#35:Z=0
	ori R17,0x0F		;#36:R17=127=0x7F
	cpi R17,0x7F		;#37:Z=1
	
	out 0x38, R17
	in r16,0x38
end:
