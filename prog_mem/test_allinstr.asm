; AVR compatible CPU test program
;  Author: Stefan Biereigel
;
; For every instruction, defines a set of test cases for which all register / SREG output is generated for validation
; "Known-Good" register values were generated using simulavr and avr-gdb
; see test_avr.ods for the corresponding register values

; -- INIT -- stack pointer to 0x0600 (only for simulator)
init_sp:	ldi r16, 0xff
		out 0x3D, r16	; AtMega8 SPL
		ldi r16, 0x01
		out 0x3E, r16	; AtMega8 SPH

; -- TEST -- NOP
test_nop:	nop

; -- TEST -- LDI
test_ldi:	ldi r16, 1
		ldi r31, 255

; -- TEST -- INC
;		result MSB set
test_inc:	ldi r16, 254
		inc r16
;		result zero
		inc r16
;		twos complement overflow
		ldi r16, 127
		inc r16

; -- TEST -- DEC
;		result zero
		ldi r16, 1
		dec r16
;		result MSB set
		dec r16
;		twos complement overflow
		ldi r16, 128
		dec r16


; -- TEST -- ADD / LSL
;		no flags from addition
test_add: 	ldi r16, 1
		ldi r17, 1
		add r16, r17
;		carry and zero flag on overflow
		ldi r16, 255
		ldi r17, 1
		add r16, r17
;		half carry flag
		ldi r16, 8
		ldi r17, 8
		add r17, r16
;		negative flag
		ldi r16, 127
		ldi r17, 1
		add r16, r17
;		logical shift left
		ldi r16, 0x40
		lsl r16
		lsl r16

; -- TEST -- ADC / ROL
;		carry not set
		ldi r16, 0
		ldi r17, 0
		clc
		adc r16, r17
;		carry set
		sec
		adc r16, r17
;		carry set and half carry
		ldi r16, 14
		ldi r17, 1
		sec
		adc r16, r17
;		carry set and overflow
		ldi r16, 254
		ldi r17, 1
		sec
		adc r16, r17
;		carry set and negative flag
		ldi r16, 126
		ldi r17, 1
		sec
		adc r16, r17
;		rotate left
		ldi r16, 0x40
		rol r16
		rol r16

; -- TEST -- SUB
;		result zero
		ldi r16, 1
		ldi r17, 1
		sub r16, r17
;		half carry
		ldi r16, 16
		ldi r17, 1
		sub r16, r17
;		TC overflow
		ldi r16, 128
		ldi r17, 1
		sub r16, r17
;		underflow and MSB set
		ldi r16, 1
		ldi r17, 2
		sub r16, r17

; -- TEST -- SUBI
;		result zero
		ldi r16, 1
		subi r16, 1
;		half carry
		ldi r16, 16
		subi r16, 1
;		TC overflow
		ldi r16, 126
		subi r16, 1
;		underflow and MSB set
		ldi r16, 1
		subi r16, 2

; -- TEST -- CP
;		result zero
		ldi r16, 1
		ldi r17, 1
		cp r16, r17
;		half carry
		ldi r16, 16
		ldi r17, 1
		cp r16, r17
;		TC overflow
		ldi r16, 128
		ldi r17, 1
		cp r16, r17
;		underflow and MSB set
		ldi r16, 1
		ldi r17, 2
		cp r16, r17

; -- TEST -- CPI
;		result zero
		ldi r16, 1
		cpi r16, 1
;		half carry
		ldi r16, 16
		cpi r16, 1
;		TC overflow
		ldi r16, 126
		cpi r16, 1
;		underflow and MSB set
		ldi r16, 1
		cpi r16, 2

; -- TEST -- RJMP
;		jump in positive direction
test_rjmp:	rjmp test_rjmp_1
		nop	; not executed
test_rjmp_2:	nop
		rjmp test_rjmp_3
;		jump in negative direction
test_rjmp_1:	nop
		rjmp test_rjmp_2
test_rjmp_3:	nop

; -- TEST -- SEC
test_sec:	sec

; -- TEST -- CLC
test_clc:	clc

; -- TEST -- BRBS
;		take forward branch
test_brbs:	sec
		brbs 0, test_brbs_2
		nop	; not executed
;		don't take branch
test_brbs_1:	clc
		brbs 0, test_brbs_2
		rjmp test_brbs_3	; executed
;		take backward branch
test_brbs_2:	sec
		brbs 0, test_brbs_1
test_brbs_3:	nop	; not executed

; -- TEST -- BRBC
;		take forward branch
test_brbc:	clc
		brbc 0, test_brbc_2
		nop	; not executed
;		don't take branch
test_brbc_1:	sec
		brbc 0, test_brbc_2
		rjmp test_brbc_3	; executed
;		take backward branch
test_brbc_2:	clc
		brbc 0, test_brbc_1
test_brbc_3:	nop	; not executed

; -- TEST -- MOV
test_mov:	ldi r16, 55
;		move from reg > 15 to reg < 15
		mov r1, r16
;		move from reg < 15 to reg < 15
		mov r2, r1
; 		move from reg < 15 to reg > 15
		mov r18, r2
;		move from reg > 15 to reg > 15
		mov r17, r16

; -- TEST -- COM
test_com:	ldi r16, 0xAA
		com r16
		com r16

; -- TEST -- EOR
test_eor:	ldi r16, 0xAA
		ldi r17, 0xFF
		ldi r18, 0x55
		eor r16, r17
		eor r16, r18

; -- TEST -- AND
test_and:	ldi r16, 0xAA
		ldi r17, 0xAA
		ldi r18, 0x55
		and r16, r17
		and r16, r18

; -- TEST -- ANDI
test_andi:	ldi r16, 0xAA
		andi r16, 0xAA
		andi r16, 0x55

; -- TEST -- OR
test_or:	ldi r16, 0xAA
		ldi r17, 0x55
		ldi r18, 0x00
		or r16, r17
		or r16, r18

; -- TEST -- ORI
test_ori:	ldi r16, 0xAA
		ori r16, 0x55
		ori r16, 0x00

; -- TEST -- LSR
test_lsr:	ldi r16, 0x02
;		no special flags set
		lsr r16
;		LSB is set before and result is zero
		lsr r16
;		carry gets cleared
		lsr r16

; -- TEST -- ASR
;		unsigned shift
test_asr:	ldi r16, 0x42
		asr r16
		asr r16
;		signed shift
		ldi r16, 0x82
		asr r16
		asr r16

; -- TEST -- PUSH / POP
test_push_pop:	ldi r16, 123
		mov r0, r16
		push r0
		pop r20
		ldi r16, 23
		push r16
		pop r10

; -- TEST -- RCALL / RET
test_rcall:	rjmp test_rcall_1
test_rcall_sr2:	push r16
		ldi r16, 0x12
		pop r16
		ret
test_rcall_1:	rcall test_rcall_sr1	; jump to test routine after PC
		ldi r16, 0xaa	; test of correct instruction run
		rcall test_rcall_sr2	; jump to test routine before PC
		rjmp test_rcall_2
test_rcall_sr1:	push r16	; test of stack handling
		ldi r16, 0x55	; test of correct writing
		pop r16
		ret
test_rcall_2:	ldi r16, 0x73	; test of correct instruction run

; -- TEST -- LD / ST
test_ld_st:	ldi r16, 0xaa
		ldi r30, 0x00	; ZL
		ldi r31, 0x01	; ZH
		st  Z, r16
		ld  r17, Z

		ldi r16, 0x55
		ldi r30, 0xff	; ZL
		ldi r31, 0x01	; ZH
		st  Z, r16
		ld  r17, Z

; -- END OF PROGRAM --
end_tests:	nop

