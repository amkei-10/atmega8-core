----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:30:37 PM
-- Design Name: 
-- Module Name: prog_cnt - Behavioral
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

use work.pkg_processor.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prog_cnt is
  port (
    clk   		: in  std_logic := '0';
    reset 		: in  std_logic := '0';
    jmpcode		: in  std_logic_vector(1 downto 0):= (others => '0');
    addr_op		: in  unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_out  	: out unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0'));
end prog_cnt;

-- Programmzaehler mit Ruecksetzen und springen

architecture Behavioral of prog_cnt is
  signal PC_reg 	 : unsigned(PMADDR_WIDTH-1 downto 0);
begin
  count : process (clk)
  begin  -- process count
    if clk'event and clk = '1' then     -- rising clock edge
      
      if reset = '1' then               -- synchronous reset (active high)
        PC_reg <= (others => '0');
        
      elsif jmpcode = jmp_code_abs then
		PC_reg <= unsigned(addr_op + 1);
		
	  else
      	PC_reg <= unsigned(PC_reg + addr_op);
		
      end if;
      
    end if;
  end process count;

  addr_out <= PC_reg;

end Behavioral;
