library ieee;
use ieee.std_logic_1164.all;

package pkg_datamem is
  
    constant read_selcode_portb 	:	std_logic_vector(2 downto 0) := "000";    
    constant read_selcode_portc 	:	std_logic_vector(2 downto 0) := "001";    
    
    constant read_selcode_pinb 		:	std_logic_vector(2 downto 0) := "010";    
    constant read_selcode_pinc 		:	std_logic_vector(2 downto 0) := "011";    
    constant read_selcode_pind 		:	std_logic_vector(2 downto 0) := "100";    
    
    constant read_selcode_dm 		:	std_logic_vector(2 downto 0) := "101"; 
    
    
    constant write_selcode_dummy 	:	std_logic_vector(2 downto 0) := "000";
    constant write_selcode_portb 	:	std_logic_vector(2 downto 0) := "001";
    constant write_selcode_portc 	:	std_logic_vector(2 downto 0) := "010";    
    
    constant write_selcode_pinb 	:	std_logic_vector(2 downto 0) := "011";    
    constant write_selcode_pinc 	:	std_logic_vector(2 downto 0) := "100";    
    constant write_selcode_pind 	:	std_logic_vector(2 downto 0) := "101";    
    
    constant write_selcode_dm 		:	std_logic_vector(2 downto 0) := "110"; 
	
end pkg_datamem;
