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
    addr_out	: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
    rel_pc_out	: out std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0'));
end instr_fetch;


architecture Behavioral of instr_fetch is
  --store rel_pc until its needed for relative jumps (WB-level)
  signal rel_pc_IF		: std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0');
  signal rel_pc_IE		: std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0');
  signal rel_pc			: std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0');
begin

  process(clk)
  begin
    if clk'event and clk = '1' then 
		instr_out <= instr_in;
		addr_out <= std_logic_vector(addr_in);							-- rcall: addr -> dm		
		
		rel_pc_IF	<=rel_pc;		
		rel_pc_IE 	<= rel_pc_IF;
		rel_pc_out 	<= rel_pc_IE;
    end if;
  end process;

  -- store relative value for branch IF Intr(13)=0 ELSE relative value for rcall,rjmp
  rel_pc <= instr_in(9)&instr_in(9)&instr_in(9 downto 3) when (instr_in(13) = '1') else instr_in(8 downto 0);

end Behavioral;
