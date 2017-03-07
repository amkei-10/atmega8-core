
; test_b -> Storing and retrieving data from memory.
;                This program sticks a bunch of data
;                    in memory and then searches for the
;                    one number that's repeated.
;                 You should end up with a 7 in R3.

.def ZL = R30
.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

; Stores #'s 1 thru 7 in addresses 0 thru 7 "randomly"
; repeating one #
	LDI   ZL,0x60
	ANDI  ZH, 0
	LDI   R16, 3
	ST    Z, R16

	INC   ZL
	LDI   R16, 4
	ST    Z, R16
	
	INC   ZL
	LDI   R16, 6
	ST    Z, R16

	INC   ZL
	LDI   R16, 2
	ST    Z, R16

	INC     ZL
	LDI     R16, 7
	ST      Z, R16

	INC     ZL
	ST      Z, R16

	INC     ZL
	LDI     R16, 1
	ST      Z, R16

	INC     ZL
	LDI     R16, 5
	ST      Z, R16

; Searches for which number is repeated, stores this # in R3.
; In this case you should end up with 7 in R3.
	EOR   	R0,R0		;#28: 0x1c
	LDI   	ZL,0x60		;#29: 0x1d
label1: 	
nop
	LD      R16, Z		;0x1e/#30	R16=0x03	R16=0x02
	ST      Z, R0		;0x1f/#31	D96=0x00	D99=0x00
	SUBI 	ZL,0x60		;0x20/#32	R30=0x00	
	MOV     R3, ZL		;0x21/#33	R03=0x00
	SUBI 	R16,-0x60	;0x22/#34	R16=0x63
	MOV     ZL, R16		;0x23/#35	R30=0x63
	SUBI 	R16, 0x60	;0x24/#36	R16=0x03
	CPI	ZL,0x60		;0x25/#37	S(Z)=0
label2: 
nop
	BREQ label2		;0x26/#38
	RJMP label1		;0x27/#39
nop
