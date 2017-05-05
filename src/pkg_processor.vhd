-------------------------------------------------------------------------------
-- Title      : Package Processor
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : pkg_processor.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package pkg_processor is
  
	constant op_nop :		std_logic_vector(3 downto 0) := "1111";  	
	constant op_add : 		std_logic_vector(3 downto 0) := "1111";  	-- ADD, LSL, ADC, ROL			--breq
	constant op_sub : 		std_logic_vector(3 downto 0) := "0011";  	-- SUB, CP, CPI, SUBI, DEC, INC	  		note: dont touch @see ALU:setup_operants
	constant op_com : 		std_logic_vector(3 downto 0) := "0111";		-- COM, SEC								note: dont touch @see ALU:setup_operants
	constant op_or  : 		std_logic_vector(3 downto 0) := "1010";  	-- OR, ORI						--brcs
	constant op_eor : 		std_logic_vector(3 downto 0) := "1110";		-- EOR					
	constant op_and : 		std_logic_vector(3 downto 0) := "1101";		-- AND, ANDI					--brne
	constant op_mov : 		std_logic_vector(3 downto 0) := "1100";		-- MOV, LDI						--ret, rcall, rjmp
	constant op_lsr : 		std_logic_vector(3 downto 0) := "1000";		-- LSR, CLC						--brcc
	constant op_asr : 		std_logic_vector(3 downto 0) := "1001";		-- ASR							
	
	-- IOMEM-addresses
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
	
	constant stackOP_push 	: std_logic_vector(1 downto 0)	:= "10";	
	constant stackOP_pop 	: std_logic_vector(1 downto 0) 	:= "01";
	
	-- jmpcodes also used as flush(low active) and increment-operant 
	constant jmpCode_inc : std_logic_vector(1 downto 0) 		:= "11";
	constant jmpCode_rel : std_logic_vector(1 downto 0) 		:= "01";
	constant jmpCode_relBranch : std_logic_vector(1 downto 0) 	:= "01";
	constant jmpCode_relNoCond : std_logic_vector(1 downto 0) 	:= "10";
	constant jmpCode_abs : std_logic_vector(1 downto 0) 		:= "00";
	
	constant opcCode_zero : std_logic_vector(1 downto 0) 	:= "00";
	constant opcCode_one : std_logic_vector(1 downto 0) 	:= "01";
	constant opcCode_carry : std_logic_vector(1 downto 0) 	:= "11";
	
end pkg_processor;
