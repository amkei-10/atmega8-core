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
	generic( div : integer := 100 );
	port(
		clk : in std_logic;
		clk_div : out std_logic
		);
end Freq_Div;

architecture Behavioral of Freq_Div is
	signal clk_reg : std_logic := '0';
begin
	process(clk)
		variable counter : integer := 0;
	begin
		if clk'event and clk = '1' then
			if counter = div then
				counter := 0;
				clk_reg <= '1';
			else
				counter := counter + 1;
				clk_reg <= '0';
			end if;
		end if;
	end process;

	clk_div <= clk_reg;

end Behavioral;
