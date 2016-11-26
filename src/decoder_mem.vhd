----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2016 22:26:49
-- Design Name: 
-- Module Name: decoder_mem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pkg_datamem.ALL;	-- definitions of selection-codes

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_mem is
    Port ( 	addr_r3x 	: in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";			
			sel_mux_dm 	: out STD_LOGIC_VECTOR (2 downto 0) := "000");
end decoder_mem;


architecture Behavioral of decoder_mem is

begin

	select_mux: process (addr_r3x)
	begin
		
		case addr_r3x is
			-- PINB
			when "0000110110" =>
				sel_mux_dm <= read_selcode_pinc;
			-- PINC
			when "0000110011" =>
				sel_mux_dm <= read_selcode_pinc;
			-- PIND
			when "0000110000" =>
				sel_mux_dm <= read_selcode_pind;
			-- PORTB
			when "0000111000" =>
				sel_mux_dm <= read_selcode_portb;			
			-- PORTC
			when "0000110101" =>
				sel_mux_dm <= read_selcode_portc;			
			when others =>
				sel_mux_dm <= read_selcode_dm;		
		end case;
				
	end process;

end Behavioral;
