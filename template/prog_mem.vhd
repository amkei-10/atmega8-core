----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:01:02 AM
-- Design Name: 
-- Module Name: prog_mem - Behavioral
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

library work;
use work.pkg_instrmem.all;

-- following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prog_mem is
    Port ( Addr : in STD_LOGIC_VECTOR (8 downto 0);
           Instr : out STD_LOGIC_VECTOR (15 downto 0));
end prog_mem;

architecture Behavioral of prog_mem is

begin
  Instr <= PROGMEM(to_integer(unsigned(Addr)));

end Behavioral;
