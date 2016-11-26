; Programm, dass Binaerwerte, die mit den 
; Schaltern eingegeben werden, in Dezimalwerte
; umrechnet und an der Siebensegmentanzeige ausgibt

; V2: Nach Inbetriebnahme durch J. Oberender:
; - 4, 5, 6 repariert
; - Cathoden signale der Segmente invertiert
; - Division durch 10 korrigiert


; Adress-Deklarationen
	
	; Definition SPH und SPL
	.equ SPL = 0x3D
	.equ SPH = 0x3E

; Fuer Simulation Stack initialisieren --> hoechste Adresse fuer 1kB -10Bit
;ldi R16, 0x03
;out SPH, R16
;ldi R16, 0xFF
;out SPL, R16

main: 
		ldi R19, 2
		ldi R18,10			;R19:R18 =  10 
		add R19, R18
ret
	
