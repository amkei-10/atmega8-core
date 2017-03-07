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

	nop
	nop
	nop
	nop
	
	ldi 	ZH, 0xFF	;Z<-0x0300	#4	
	eor	ZH,ZH		;Z<-0x00	#5
	ldi	ZH,0x03		;Z<-0x0300	#6
	ldi	ZL,0xE8		;Z<-1000d	#7
	ldi	R16, 0x01	;R16<-0x01	#8
	ldi	R17, 0x0A	;R17<-0x0A	#9
	
	mov	R20, R16	;R20<-0x01	#10
	add	R20, R17	;R20<-0x0B	#11
	inc	R20		;R20<-0x0C	#12
	
	mov	R21, R17	;R21<-0x0A	#13
	sub	R21, R16	;R21<-0x09	#14
	dec	R21		;R21<-0x08	#15
	subi	R21, 0x03	;R21<-0x05	#16
	
	ldi	R18, 0x04	;R18<-0x04	#17
	ldi	R19, 0x0F	;R19<-0x0F	#18
	and	R21, R18	;R21<-0x04	#19
	ori	R21, 0xAF	;R21<-0xAF	#20
	andi	R21, 0xF0	;R21<-0xA0	#21
	
	cpi	R21, 0x00
	cpi	R21, 0xA0
	
	nop			;			
	