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

entity instr_fetch is
  port (
    clk   		: in std_logic := '0';
    instr_in 	: in STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
    instr_out	: out STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
    addr_in		: in unsigned (PMADDR_WIDTH-1 downto 0);
    addr_out	: out unsigned (PMADDR_WIDTH-1 downto 0));
end instr_fetch;

-- Rudimentaerer Programmzaehler ohne Ruecksetzen und springen...

architecture Behavioral of instr_fetch is
begin

  process(clk)
  begin  -- process count
    if clk'event and clk = '1' then 
		instr_out <= instr_in;
		addr_out <= addr_in;
    end if;
  end process;

end Behavioral;
