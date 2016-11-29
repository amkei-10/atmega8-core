library ieee;
use ieee.std_logic_1164.all;

package pkg_datamem is
  
    constant selcode_mem_pinb 	:	std_logic_vector(3 downto 0) := "0000";
    constant selcode_mem_pinc 	:	std_logic_vector(3 downto 0) := "0001";
    constant selcode_mem_pind 	:	std_logic_vector(3 downto 0) := "0010";
    constant selcode_mem_portb 	:	std_logic_vector(3 downto 0) := "0011";
    constant selcode_mem_portc 	:	std_logic_vector(3 downto 0) := "0100";
    constant selcode_mem_segen 	:	std_logic_vector(3 downto 0) := "0101";
    constant selcode_mem_seg0 	:	std_logic_vector(3 downto 0) := "0110";
    constant selcode_mem_seg1 	:	std_logic_vector(3 downto 0) := "0111";
    constant selcode_mem_seg2 	:	std_logic_vector(3 downto 0) := "1000";
    constant selcode_mem_seg3 	:	std_logic_vector(3 downto 0) := "1001";
    constant selcode_mem_dm 	:	std_logic_vector(3 downto 0) := "1010";
    
	-- see portmap (was given)
	constant def_addr_pinb	: std_logic_vector(7 downto 0) := "00110110"; 	-- "0x36"
	constant def_addr_pinc 	: std_logic_vector(7 downto 0) := "00110011";	-- "0x33"
	constant def_addr_pind 	: std_logic_vector(7 downto 0) := "00110000";	-- "0x30"	
	constant def_addr_portb	: std_logic_vector(7 downto 0) := "00111000"; 	-- "0x38"
	constant def_addr_portc	: std_logic_vector(7 downto 0) := "00110101";	-- "0x35"
	
	constant def_addr_segen	: std_logic_vector(7 downto 0) := "01000000";	-- "0x40"
	constant def_addr_seg0	: std_logic_vector(7 downto 0) := "01000001";	-- "0x41"
	constant def_addr_seg1	: std_logic_vector(7 downto 0) := "01000010";	-- "0x42"
	constant def_addr_seg2	: std_logic_vector(7 downto 0) := "01000011";	-- "0x43"
	constant def_addr_seg3	: std_logic_vector(7 downto 0) := "01000100";	-- "0x44"
	
end pkg_datamem;
