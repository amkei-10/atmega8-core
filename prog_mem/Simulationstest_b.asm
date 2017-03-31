
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
	LDI   ZL,0x60	;#04	
	ANDI  ZH, 0	;#05
	LDI   R16, 3	;#06
	ST    Z, R16	;#07	DM(96)=0x03

	INC   ZL	;#08
	LDI   R16, 4	;#09
	ST    Z, R16	;#10	DM(97)=0x04
	
	INC   ZL	;#11
	LDI   R16, 6	;#12
	ST    Z, R16	;#13	DM(98)=0x06

	INC   ZL	;#14
	LDI   R16, 2	;#15
	ST    Z, R16	;#16	DM(99)=0x02

	INC     ZL	;#17
	LDI     R16, 7	;#18
	ST      Z, R16	;#19	DM(100)=0x07

	INC     ZL	;#20
	ST      Z, R16	;#21	DM(101)=0x07

	INC     ZL	;#22
	LDI     R16, 1	;#23
	ST      Z, R16	;#24	DM(102)=0x01

	INC     ZL	;#25
	LDI     R16, 5	;#26
	ST      Z, R16	;#27	DM(103)=0x05

; Searches for which number is repeated, stores this # in R3.
; In this case you should end up with 7 in R3.
	EOR   	R0,R0	;#28: 0x1c
	LDI   	ZL,0x60	;#29: 0x1d
label1: 	
	LD      R16, Z		;0x1e/#30	R16=0x03	R16=0x02
	ST      Z, R0		;0x1f/#31	D96=0x00	D99=0x00
	SUBI 	ZL,0x60		;0x20/#32	R30=0x00	
	MOV     R3, ZL		;0x21/#33	R03=0x00
	SUBI 	R16,-0x60	;0x22/#34	R16=0x63
	MOV     ZL, R16		;0x23/#35	R30=0x63
	SUBI 	R16, 0x60	;0x24/#36	R16=0x03
	CPI	ZL,0x60		;0x25/#37	S(Z)=0
label2: 
	BREQ label2		;0x26/#38
	RJMP label1		;0x27/#39
nop
