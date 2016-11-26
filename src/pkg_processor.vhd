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
	constant op_lsl: 		std_logic_vector(4 downto 0) := "01110";	
	constant op_ld: 		std_logic_vector(4 downto 0) := "01111";
	
	constant op_st: 		std_logic_vector(4 downto 0) := "10000";
	
end pkg_processor;
