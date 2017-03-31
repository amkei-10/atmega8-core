library ieee;
use ieee.std_logic_1164.all;

package pkg_processor is
  
	-- GRP: operations with two operants (@see decoder, some operations are converted)
    constant op_nop :		std_logic_vector(4 downto 0) := "00000";  -- NoOperation (als Addition implementiert, die Ergebnisse (werden aber nicht gespeichert...)
  
    constant op_add : 		std_logic_vector(4 downto 0) := "00000";  	-- ADD, LSL				--brcc
	constant op_sub : 		std_logic_vector(4 downto 0) := "00001";  	-- SUB, CP, CPI, SUBI	--brne
	constant op_or  : 		std_logic_vector(4 downto 0) := "00010";  	-- OR, ORI				--brcs

	constant op_adc : 		std_logic_vector(4 downto 0) := "00101";  	-- ADC, ROL, RJMP		--rjmp
	constant op_and : 		std_logic_vector(4 downto 0) := "00110";	-- AND, ANDI			--rcall
	constant op_eor : 		std_logic_vector(4 downto 0) := "00111";	-- EOR					--ret

	constant op_mov : 		std_logic_vector(4 downto 0) := "01000";	-- MOV, LDI				
	constant op_dec : 		std_logic_vector(4 downto 0) := "11011";	-- DEC					--breq
	constant op_inc : 		std_logic_vector(4 downto 0) := "11100";	-- INC
	constant op_com : 		std_logic_vector(4 downto 0) := "11001";	-- COM
	constant op_asr : 		std_logic_vector(4 downto 0) := "11010";	-- ASR
	constant op_lsr : 		std_logic_vector(4 downto 0) := "11111";	-- LSR		
	constant op_sec : 		std_logic_vector(4 downto 0) := "11100";  	-- SEC, CLC
	
	
	-- specific IOMEM-addresses
	constant def_addr_pinb	: std_logic_vector(9 downto 0) := "00"&x"36"; 	-- "0x36"	54d
	constant def_addr_pinc 	: std_logic_vector(9 downto 0) := "0000110011";	-- "0x33"	51d
	constant def_addr_pind 	: std_logic_vector(9 downto 0) := "0000110000";	-- "0x30"	48d
	constant def_addr_portb	: std_logic_vector(9 downto 0) := "0000111000"; -- "0x38"	56d
	constant def_addr_portc	: std_logic_vector(9 downto 0) := "0000110101";	-- "0x35"	53d
	
	constant def_addr_segen	: std_logic_vector(9 downto 0) := "0001000000";	-- "0x40"
	constant def_addr_seg0	: std_logic_vector(9 downto 0) := "0001000001";	-- "0x41"
	constant def_addr_seg1	: std_logic_vector(9 downto 0) := "0001000010";	-- "0x42"
	constant def_addr_seg2	: std_logic_vector(9 downto 0) := "0001000011";	-- "0x43"
	constant def_addr_seg3	: std_logic_vector(9 downto 0) := "0001000100";	-- "0x44"
	
	-- progmem = 512 instr
	constant PMADDR_WIDTH : integer := 9;
	
	constant mdec_op_push 	: std_logic_vector(2 downto 0)	:= "010";	
	constant mdec_op_rcall 	: std_logic_vector(2 downto 0)	:= "011";	
	constant mdec_op_pop 	: std_logic_vector(2 downto 0) 	:= "001";	--also used for ret
	constant mdec_op_ld 	: std_logic_vector(2 downto 0)	:= "100";	
	constant mdec_op_st 	: std_logic_vector(2 downto 0)	:= "110";	
	
	constant jmp_code_inc : std_logic_vector(1 downto 0) 	:= "01";
	constant jmp_code_rel : std_logic_vector(1 downto 0) 	:= "10";
	constant jmp_code_abs : std_logic_vector(1 downto 0) 	:= "11";
	
end pkg_processor;
