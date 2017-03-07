library ieee;
use ieee.std_logic_1164.all;
-- ---------------------------------------------------------------------------------
-- Memory initialisation package
-- ---------------------------------------------------------------------------------
package pkg_instrmem is

	type t_instrMem   is array(0 to 512-1) of std_logic_vector(15 downto 0);
	constant PROGMEM : t_instrMem := (
		"1110000000110010",
		"1110000000101010",
		"0000111100110010",
		"1001010100001000",
		
		others => (others => '0')
	);

end package pkg_instrmem;
