----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:06:23 PM
-- Design Name: 
-- Module Name: Reg_File - Behavioral
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


entity Reg_File is
    Port ( clk			: in STD_LOGIC := '0';
           w_e_regfile 	: in STD_LOGIC := '0';
           addr_opa 	: in STD_LOGIC_VECTOR (4 downto 0) := "00000";
           addr_opb 	: in STD_LOGIC_VECTOR (4 downto 0) := "00000";
           data_ldi		: in STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           data_opa 	: out STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           data_opb 	: out STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           addr_r3x		: out STD_LOGIC_VECTOR (9 downto 0) := "0000000000");
end Reg_File;

-- ACHTUNG!!! So einfach wird das mit dem Registerfile am Ende nicht.
-- hier muss noch einiges bzgl. Load/Store gemacht werden...


architecture Behavioral of Reg_File is
  type regs is array(31 downto 0) of std_logic_vector(7 downto 0); 
  signal register_speicher:regs := (others => (others => '0'));  
begin
  
  -- purpose: einfacher Schreibprozess für rudimentaeres Registerfile
  -- type   : sequential
  -- inputs : clk, addr_opa, w_e_regfile, data_res
  -- outputs: register_speicher
  registerfile: process (clk)
  begin  -- process registerfile
    if clk'event and clk = '1' then  -- rising clock edge
      if w_e_regfile = '1' then
        register_speicher(to_integer(unsigned(addr_opa))) <= data_ldi;
      end if;
    end if;
  end process registerfile;

  -- nebenlaeufiges Lesen der Registerspeicher
  data_opa <= register_speicher(to_integer(unsigned(addr_opa)));
  data_opb <= register_speicher(to_integer(unsigned(addr_opb)));
  
  --addr_r3x <= register_speicher(to_integer(unsigned(addr_opa)+1))(1 downto 0) & register_speicher(to_integer(unsigned(addr_opa)));
  addr_r3x <= register_speicher(31)(1 downto 0) & register_speicher(30);
  
end Behavioral;
