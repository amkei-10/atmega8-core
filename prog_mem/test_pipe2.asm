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
	
	ldi 	r16,0x16
	ldi 	r17,0x17
	ldi 	r18,0x18	
	ldi	r19,0x19
	ldi	r20,0x20
	ldi	r28,0x01
	ldi	r29,0x01
	
	;nop
	mov	r9,r18
	
	ldi	r18,0x02
	mov	R19,r18

	mov	r18,r17
	mov	r17,r16		;r17=0x16

	ldi 	r21,0b11110000	;r21=11110000
	ori	r21,0b00001010	;r21=11111010
	andi	r21,0b00111100	;r21=00111000
	
	mov	r22,r21		;fw_opb
	mov	r23,r22		;fw_opb
	mov	r24,r23		;fw_opb
	mov	r25,r24		;fw_opb
	
	nop
	nop
	nop
	nop
	
	add             r16,r28		;r16=0x17
	add             r16,r29		;r16=0x18
	add             r16,r28		;r16=0x19
	add             r16,r29		;r16=0x1A
	add             r16,r28		;r16=0x1B
	mov		r16,r17		;r16=0x16
	add             r16,r29		;r16=0x17
	add             r16,r28		;r16=0x18
	mov		r16,r20		;r16=0x20
	add             r16,r29		;r16=0x21
end:
