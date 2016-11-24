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
use work.pkg_datamem.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_mem is
    Port ( 	addr_r3x 	: in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
			--w_e_portb : out STD_LOGIC := '0';
			--w_e_portc : out STD_LOGIC := '0';
			--w_e_pinb 	: out STD_LOGIC := '0';
			--w_e_pinc 	: out STD_LOGIC := '0';
			--w_e_pind 	: out STD_LOGIC := '0';
			--w_e_dm 	: out STD_LOGIC := '0';
			w_e_datamem : in STD_LOGIC := '0';
			sel_w_e_dm	: out STD_LOGIC_VECTOR (2 downto 0) := "000";
			sel_mux_dm 	: out STD_LOGIC_VECTOR (2 downto 0) := "000");
end decoder_mem;

architecture Behavioral of decoder_mem is

begin

	dec_mux: process (addr_r3x)
	begin
		
		case addr_r3x(7 downto 0) is
			-- PIND
			when "00110000" =>
				sel_mux_dm <= read_selcode_pind;
			-- PINC
			when "00110011" =>
				sel_mux_dm <= read_selcode_pinc;
			-- PINB
			when "00110110" =>
				sel_mux_dm <= read_selcode_pinc;
			-- PORTC
			when "00110101" =>
				sel_mux_dm <= read_selcode_portc;
			-- PORTB
			when "00111000" =>
				sel_mux_dm <= read_selcode_portb;
			when others =>
				sel_mux_dm <= read_selcode_dm;		
		end case;

		
	end process;

end Behavioral;
