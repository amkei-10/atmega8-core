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
	
	eor	ZH,ZH
	ldi	ZH,0x03
	ldi	ZL,0xE8		;Z<-1000d		#6
	ldi	R16, 0x06	;R16<-0x06		#7
	ldi	R17, 0x04	;R17<-0x04		#8
	st	Z, R16		;dm(1000)<-0x06		#9
	push	R17		;sp(1023)<-0x04		#10
	add	R17, R16	;R17<-0x0A		#11
	push 	R16		;sp(1022)<-0x06		#12
	push	R17		;sp(1021)<-0x0a		#13
	
	ldi	ZL,0xFD		;Z<-1021		#14
	ld	R15, Z		;R15<-0x0a		#15
	inc	ZL		;Z<-1022		#16
	ld	R14, Z		;R14<-0x06		#17
	
	pop	R10		;R10<-0x0a		#18
	pop	R9		;R9<-0x06		#19
	nop			;			#20
	