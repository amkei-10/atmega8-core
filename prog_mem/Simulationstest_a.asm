; testa -> Counts # of one's in the 8 bit number in R16.
; NOTE: you should end up with a 4 in R1. 

main:
	NOP
	NOP
	NOP
	NOP

	ldi  R16, 0x5A	;#4 R16=0x5A
	
	mov  R2, R16	;#5 R2=0x5A (0101 1010)
	eor  R1, R1	;#6 R1=0x00
	ldi  R17, 8	;#7 R17=0x08
label1: 
	LSL  R2		;#8
	brcc label2	;#9
	inc  R1		;#10
label2: 
	dec R17		;#11	if R17=0x00	-> 	Z=1	else Z=0
	brne label1	;#12	if Z=0		->	branch
label3:
	rjmp label3	;#13
;ret			;#14


 
;#1  #2  #3  #4  #5  #6  #7  #8  #9	R2=1011 0100 C=0
;#11 #12 						      R17=7
;#8  #9  #10 #11 #12			R2=0110 1000 C=1 R1=1 R17=6
;#8  #9  #11 #12			R2=1101 0000 C=0 R1=1 R17=5
;#8  #9  #10 #11 #12			R2=1101 0000 C=1 R1=2 R17=4
;#8  #9  #11 #12			R2=1010 0000 C=0 R1=2 R17=3
;#8  #9  #10 #11 #12			R2=0100 0000 C=1 R1=3 R17=2
;#8  #9  #11 #12			R2=1000 0000 C=0 R1=1 R17=1
;#8  #9  #10 #11 #12 #13 #14		R2=0000 0000 C=1 R1=4 R17=0