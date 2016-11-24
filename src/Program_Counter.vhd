----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:30:37 PM
-- Design Name: 
-- Module Name: Program_Counter - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter is
  port (
    reset 		: in  std_logic := '0';
    clk   		: in  std_logic := '0';
    addr_pm  	: out std_logic_vector (8 downto 0) := "000000000";
    rel_pc		: in  std_logic_vector (6 downto 0) := "0000000");
end Program_Counter;

-- Rudimentaerer Programmzaehler ohne Ruecksetzen und springen...

architecture Behavioral of Program_Counter is
  signal PC_reg : std_logic_vector(8 downto 0);
begin
  count : process (clk)
  begin  -- process count
    if clk'event and clk = '1' then     -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)
        PC_reg <= "000000000";        
      else
        PC_reg <= std_logic_vector(unsigned(PC_reg) + unsigned(rel_pc(6)&rel_pc(6)&rel_pc(6 downto 0)) + 1);
      end if;
    end if;
  end process count;

  addr_pm <= PC_reg;

end Behavioral;
