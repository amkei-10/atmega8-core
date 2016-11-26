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

main: 
	ldi	R16, 0
	rjmp test
	rjmp fail

test:
	ldi ZH, 0
	ldi R18, 3
	ldi R16, 10
	ldi R17, 0
	add R17, R16	; r17 = 10
	add R17, R17	; r17 = 20 
	add R17, R17	; r17 = 40
	add R16, R17	; r16 = 50
	add R16, R18	; r16 = 53
	mov R17, R16	; r17 = 53
	add R17, R18 	; r17 = 56
	mov ZL, R16		; ZL = 53
	st 	Z, R17		; LEDH = 56
	ld 	ZL, Z 		; ZL = 56
	st 	Z, R16		; LEDL = 53
	ld 	ZL, Z 		; ZL = 53
	st  Z, R18		; LEDH = 3 
	ld 	R1, Z 		; R1 = 3
	cp  R1, R18		
	brne fail

	ldi R16, 1
	ldi R17, 11
	mov ZH, R16
	mov ZL, R17
	st 	Z, R18
	ld 	ZH, Z
	st 	Z, R16
	ld  ZL, Z
	st 	Z, R18
	ld 	R2, Z
	cp 	R2, R18
	brne fail
	rjmp pass

fail:
	ldi ZH, 0
	ldi R16, 0b00111000
	com R16
	ldi ZL, SEG0
	st Z, R16

	ldi R16, 0b00000110
	com R16
	ldi ZL, SEG1
	st Z, R16

	ldi R16, 0b01110111
	com R16
	ldi ZL, SEG2
	st Z, R16

	ldi R16, 0b01110001
	com R16
	ldi ZL, SEG3
	st Z, R16

	ldi ZL, SEG_ER
	ldi R16, 0x0F
	st Z, R16
	rjmp main

pass:
	ldi ZH, 0
	ldi R16, 0b01101101
	com R16
	ldi ZL, SEG0
	st Z, R16

	ldi R16, 0b01101101
	com R16
	ldi ZL, SEG1
	st Z, R16

	ldi R16, 0b01110111
	com R16
	ldi ZL, SEG2
	st Z, R16

	ldi R16, 0b01110011
	com R16
	ldi ZL, SEG3
	st Z, R16

	ldi ZL, SEG_ER
	ldi R16, 0x0F
	st Z, R16
	rjmp main

