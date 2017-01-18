library ieee;
use ieee.std_logic_1164.all;

package pkg_processor is
  
    constant op_NOP :		std_logic_vector(4 downto 0) := "00000";  -- NoOperation (als Addition implementiert, die Ergebnisse (werden aber nicht gespeichert...)
  
    constant op_add : 		std_logic_vector(4 downto 0) := "00000";  -- Addition
	constant op_sub : 		std_logic_vector(4 downto 0) := "00001";  -- Subtraction
	constant op_or  : 		std_logic_vector(4 downto 0) := "00010";  -- bitwise OR
	constant op_ldi : 		std_logic_vector(4 downto 0) := "00011";  -- Load immediate

	constant op_cp  : 		std_logic_vector(4 downto 0) := "00100";  -- compare
	constant op_adc : 		std_logic_vector(4 downto 0) := "00101";  -- rotate-left / add with carry
	constant op_and : 		std_logic_vector(4 downto 0) := "00110";	 -- AND
	constant op_eor : 		std_logic_vector(4 downto 0) := "00111";	 -- EOR

	constant op_mov : 		std_logic_vector(4 downto 0) := "01000";	 -- MOV
	constant op_com : 		std_logic_vector(4 downto 0) := "01001";	 -- COM
	constant op_asr : 		std_logic_vector(4 downto 0) := "01010";	 -- ASR
	constant op_dec : 		std_logic_vector(4 downto 0) := "01011";	 -- DEC

	constant op_inc : 		std_logic_vector(4 downto 0) := "01100";	 -- INC
	constant op_lsr : 		std_logic_vector(4 downto 0) := "01101";	 -- LSR	
	constant op_ld: 		std_logic_vector(4 downto 0) := "01110";	
	constant op_st: 		std_logic_vector(4 downto 0) := "01111";
		
	constant op_subi: 		std_logic_vector(4 downto 0) := "10000";
	constant op_ori: 		std_logic_vector(4 downto 0) := "10001";
	constant op_andi: 		std_logic_vector(4 downto 0) := "10010";
	
	
	-- specific IOMEM-addresses
	constant def_addr_pinb	: std_logic_vector(9 downto 0) := "0000110110"; -- "0x36"
	constant def_addr_pinc 	: std_logic_vector(9 downto 0) := "0000110011";	-- "0x33"
	constant def_addr_pind 	: std_logic_vector(9 downto 0) := "0000110000";	-- "0x30"	
	constant def_addr_portb	: std_logic_vector(9 downto 0) := "0000111000"; -- "0x38"
	constant def_addr_portc	: std_logic_vector(9 downto 0) := "0000110101";	-- "0x35"
	
	constant def_addr_segen	: std_logic_vector(9 downto 0) := "0001000000";	-- "0x40"
	constant def_addr_seg0	: std_logic_vector(9 downto 0) := "0001000001";	-- "0x41"
	constant def_addr_seg1	: std_logic_vector(9 downto 0) := "0001000010";	-- "0x42"
	constant def_addr_seg2	: std_logic_vector(9 downto 0) := "0001000011";	-- "0x43"
	constant def_addr_seg3	: std_logic_vector(9 downto 0) := "0001000100";	-- "0x44"
	
	constant PMADDR_WIDTH : integer := 9;
	
	constant mdec_op_rcall : std_logic_vector(2 downto 0) := "111";
	constant mdec_op_push : std_logic_vector(2 downto 0) := "110";
	constant mdec_op_ret : std_logic_vector(2 downto 0) := "011";
	constant mdec_op_pop : std_logic_vector(2 downto 0) := "001";
	
end pkg_processor;
