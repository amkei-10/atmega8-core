-------------------------------------------------------------------------------
-- Title      : RAM
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : ram.vhd
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
use IEEE.NUMERIC_STD.ALL;

use work.pkg_processor.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ram is
	generic( REG_WIDTH : integer := PMADDR_WIDTH;
			 SLOTS	   : integer := 1024 );
    port ( clk      : in STD_LOGIC;
           data_in	: in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
           addr 	: in STD_LOGIC_VECTOR (9 downto 0);           
           w_e      : in std_logic;
           en       : in std_logic;
		   data_out : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0));
end ram;

architecture Behavioral of ram is	
	type 	memslot is array(SLOTS-1 downto 0) of std_logic_vector(REG_WIDTH-1 downto 0);
	signal 	memory:memslot := (others => (others => '0'));	
begin
	
	process(clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if w_e = '1' then
					memory(to_integer(unsigned(addr))) <= data_in;
				--else
					--#BlockRAM -> synched read
					--data_out <= memory(to_integer(unsigned(addr)));
				end if;
			end if;
		end if;
	end process;
	
	--#distributed RAM -> asynch read
	data_out <= memory(to_integer(unsigned(addr)));
	
end Behavioral;
