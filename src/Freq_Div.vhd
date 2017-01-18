-------------------------------------------------------------------------------
-- Title      : decoder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : decoder.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2015-06-25
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  	Description
-- 2015-06-23  1.0      mkellner	Created
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
	--signal clk_reg : std_logic := '0';
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

	--clk_out <= clk_reg;

end Behavioral;
