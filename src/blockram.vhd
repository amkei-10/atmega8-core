----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2016 00:22:05
-- Design Name: 
-- Module Name: blockram_mem - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

use work.pkg_processor.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blockram is
    port ( clk      : in STD_LOGIC;
           data_in	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
           addr 	: in STD_LOGIC_VECTOR (9 downto 0);           
           w_e      : in std_logic;
           en       : in std_logic;
		   data_out : out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0));
end blockram;

architecture Behavioral of blockram is	
	type 	memslot is array(1023 downto 0) of std_logic_vector(PMADDR_WIDTH-1 downto 0);
	signal 	memory:memslot := (others => (others => '0'));	
begin
	
	process(clk)
	begin
		if clk'event and clk = '1' then
			if en = '1' then
				if w_e = '1' then
					memory(to_integer(unsigned(addr))) <= data_in;
					--data_out <= data_in;
				--else
					--data_out <= memory(to_integer(unsigned(addr)));
				end if;
			end if;
		end if;
	end process;
	
	--used as distributed RAM (!) -> asynchrone readout
	--todo: rename or fallback to blockram when using pipelines(!!!)
	data_out <= memory(to_integer(unsigned(addr)));
	
end Behavioral;
