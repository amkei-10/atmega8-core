-------------------------------------------------------------------------------
-- Title      : Frequency Divider
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : Freq_Div.vhd
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
library work;

entity Freq_Div is
	generic( div : integer := 1 );
	port(
		clk_in : in std_logic;
		clk_out : out std_logic
		);
end Freq_Div;

architecture Behavioral of Freq_Div is
begin
	process(clk_in)
		variable counter : integer range 0 to div := 0;
	begin
		if clk_in'event and clk_in = '1' then
			
			clk_out <= '0';
			counter := counter + 1;
			
			if counter = div then
				clk_out <= '1';
				counter := 0;
			end if;
			
		end if;
	end process;

end Behavioral;
