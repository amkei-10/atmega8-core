; Programm, dass Binaerwerte, die mit den 
; Schaltern eingegeben werden, in Dezimalwerte
; umrechnet und an der Siebensegmentanzeige ausgibt

; V2: Nach Inbetriebnahme durch J. Oberender:
; - 4, 5, 6 repariert
; - Cathoden signale der Segmente invertiert
; - Division durch 10 korrigiert


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

	; Definition SPH und SPL
	.equ SPL = 0x3D
	.equ SPH = 0x3E

; Fuer Simulation Stack initialisieren --> hoechste Adresse fuer 1kB -10Bit
;ldi R16, 0x03
;out SPH, R16
;ldi R16, 0xFF
;out SPL, R16

main: 
	; Schalter einlesen
	eor ZH, ZH
	ldi ZL, SWH
	ld R10, Z
	ldi ZL, SWL
	ld R9, Z

	; LEDs entsprechend schreiben
	ldi ZL, LEDH
	st Z, R10
	ldi ZL, LEDL
	st Z, R9

	rcall bin2dez ; R24:R21 <- Dezimalwert von R10:R9
	
	mov R17, R21
	rcall dez2seg ; R16 <- Wert, der entsprechend R17 in SEG-Register passt
	com R16
	ldi ZL, SEG0
	st Z, R16

	mov R17, R22
	rcall dez2seg
	com R16
	ldi ZL, SEG1
	st Z, R16

	mov R17, R23
	rcall dez2seg
	com R16
	ldi ZL, SEG2
	st Z, R16

	mov R17, R24
	rcall dez2seg
	com R16
	ldi ZL, SEG3
	st Z, R16

	ldi ZL, SEG_ER
	ldi R16, 0x0F
	st Z, R16

rjmp main

; R16 <- Wert, der entsprechend R17 in SEG-Register passt
dez2seg:
	dez2seg_0: 
		cpi R17, 0
		brne dez2seg_1
		ldi R16, 0b00111111
		ret
	dez2seg_1:
		cpi R17, 1
		brne dez2seg_2
		ldi R16, 0b00000110
		ret
	dez2seg_2:
		cpi R17, 2
		brne dez2seg_3
		ldi R16, 0b01011011
		ret
	dez2seg_3:
		cpi R17, 3
		brne dez2seg_4
		ldi R16, 0b01001111
		ret
	dez2seg_4:
		cpi R17, 4
		brne dez2seg_5
		ldi R16, 0b01100110
		ret
	dez2seg_5:
		cpi R17, 5
		brne dez2seg_6
		ldi R16, 0b01101101
		ret
	dez2seg_6:
		cpi R17, 6
		brne dez2seg_7
		ldi R16, 0b01111101
		ret
	dez2seg_7:
		cpi R17, 7
		brne dez2seg_8
		ldi R16, 0b00000111
		ret
	dez2seg_8:
		cpi R17, 8
		brne dez2seg_9
		ldi R16, 0b01111111
		ret
	dez2seg_9:
		cpi R17, 9
		brne dez2seg_e
		ldi R16, 0b01101111
		ret
	dez2seg_e:
		ldi R16, 0b11111001
ret

; bin2dez:  R24:R21 <- Dezimalwert von R10:R9
bin2dez: 
	push R16
	push R10
	push R9
	rcall div16_10 ;R16 <- R10:R9 % 10, R10:R9 <- R10:R9 / 10
	mov R21, R16 ;R21 = R10:R9 % 10; R10:R9 = R10:R9 / 10
	rcall div16_10
	mov R22, R16
	rcall div16_10
	mov R23, R16
	rcall div16_10
	mov R24, R16
	pop R9
	pop R10
	pop R16
ret

; div16_10 ;R16 <- R10:R9 % 10, R10:R9 <- R10:R9 / 10
div16_10: 
	; Da SBC und ROL nicht implementiert sind, muessen wir hier Klimzuege machen. 
	; Idee: von R10:R9 wird solange 10 subtrahiert, bis R10:R9 kleiner 0
	; da einmal zu viel subtrahiert wurde muss Ergebniszaehler und R10:R9 danach noch korrigiert werden

	push R18
	push R19
	push R20
	push R21
	push R22
	push R23


	ldi R19, 0xFF
	ldi R18,-10		;R19:R18 =  -10 
	
	ldi R20, 1
	ldi R21, 0		; R21:R20 = 1
	
	ldi R22, 0
	ldi R23, 0		; R23:R22 = 0 --> Ergebniszaehler
	

	div16_10_1: 
		

		add R22, R20
		adc R23, R21	;Ergebniszahler ++

		add R9, R18
		adc R10, R19	; R10:R9 += (-10)

		brcc div16_10_2	; wenn Betrag von R19:R18 > R10:R9, dann ist c=0;

	rjmp div16_10_1

	div16_10_2:	
		
		; einmal zu viel 10 abgezogen --> muss korrigiert werden: 
	  	ldi R20, 0xFF
		ldi R21, 0xFF		; R21:R20 = -1

		add R22, R20
		adc R23, R21		; Ergebniszahler --

		ldi R19, 0x00
		ldi R18,10		;R19:R18 =  10 

		add R9, R18
		adc R10, R19	; R10:R9 += 10

		;in R10:R9 steht jetzt der Rest (eine Zahl zwischen 0 und 9)
		mov R16, R9 ; in R16 steht jetzt der Rest

		mov R10, R23
		mov R9, R22	  ; in R10:R9 jetzt Ergebnis der ganzzahlingen Division

	pop R23
	pop R22
	pop R21
	pop R20
	pop R19
	pop R18
ret
	
