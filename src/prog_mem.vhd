-------------------------------------------------------------------------------
-- Title      : Program Memory
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : prog_mem.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.pkg_instrmem.all;
use work.pkg_processor.all;

-- following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity prog_mem is
    Port ( clk      : in STD_LOGIC;
           data_in	: in STD_LOGIC_VECTOR (15 downto 0);           
           w_e      : in std_logic;
           en       : in std_logic;		   
		   addr 	: in unsigned (PMADDR_WIDTH-1 downto 0);
           instr 	: out STD_LOGIC_VECTOR (15 downto 0)	:= (others => '0'));
end prog_mem;

architecture Behavioral of prog_mem is
	--type 	t_instrMem is array(1023 to 0) of std_logic_vector(15 downto 0);
	signal 	memory:t_instrMem := PROGMEM;	
begin

	process(clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if w_e = '1' then
					memory(to_integer(unsigned(addr))) <= data_in;
				else
					instr <= memory(to_integer(unsigned(addr)));
				end if;
			end if;
		end if;
	end process;

  --instr <= memory(to_integer(addr));

end Behavioral;
