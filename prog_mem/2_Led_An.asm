;
; ********************************************
; * Eine LED ausschalten mit einem ATtiny13  *
; * (C)2016 by http://www.gsc-elektronic.net *
; ********************************************
;
.NOLIST ; Ausgabe im Listing unterdruecken
.INCLUDE "tn13def.inc" ; Port-Definitionen lesen 
.LIST ; Ausgabe im Listing einschalten
;
	sbi DDRB,DDB0 ; Portpin PB0 auf Ausgang
	sbi PORTB,PORTB0 ; Portpin PB0 auf Null
;
; Ende Quellcode
;
