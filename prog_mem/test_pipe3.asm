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

	nop			;#0:
	nop			;#1:
	nop			;#2:
	nop			;#3:	
	
	eor	r1,r1
	eor	r2,r2
	eor	r3,r3
	
	ldi 	r16,0x16
	ldi	r17,0x01
	ldi	r21,0x01
	ldi	r22,0x02
	
	add             r16,r21		;r16=0x17
	add             r16,r22		;r16=0x19
	add             r16,r21		;r16=0x1A
	add             r16,r22		;r16=0x1C
	add             r16,r21		;r16=0x1D
	mov		r16,r17		;r16=0x01
	add             r16,r22		;r16=0x03
	add             r16,r21		;r16=0x04
	mov		r16,r17		;r16=0x01
	add             r16,r21		;r16=0x02
end:
