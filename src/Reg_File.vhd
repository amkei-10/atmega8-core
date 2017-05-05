-------------------------------------------------------------------------------
-- Title      : Register File
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : Reg_File.vhd
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


entity Reg_File is
    Port ( clk			: in STD_LOGIC := '0';
           w_e 			: in std_logic;
           addr_opa_w 	: in STD_LOGIC_VECTOR (4 downto 0) := "00000";
           addr_opa 	: in STD_LOGIC_VECTOR (4 downto 0) := "00000";
           addr_opb 	: in STD_LOGIC_VECTOR (4 downto 0) := "00000";
           data_opim	: in STD_LOGIC_VECTOR (7 downto 0) := x"00";
           data_opa 	: out STD_LOGIC_VECTOR (7 downto 0) := x"00";
           data_opb 	: out STD_LOGIC_VECTOR (7 downto 0) := x"00";
           addr_Z		: out STD_LOGIC_VECTOR (9 downto 0) := "0000000000");
end Reg_File;


architecture Behavioral of Reg_File is
  type regs is array(31 downto 0) of std_logic_vector(7 downto 0); 
  signal reg_mem:regs := (others => (others => '0'));
begin
  
  -- purpose: Schreibprozess für Registerfile
  -- type   : sequential
  -- inputs : clk, addr_opa, w_e, data_res
  -- outputs: reg_mem
  registerfile: process (clk)
  begin 
    if clk'event and clk = '1' then
      if w_e = '1' then
        reg_mem(to_integer(unsigned(addr_opa_w))) <= data_opim;
      end if;
    end if;
  end process registerfile;

  -- nebenlaeufiges Lesen der Registerspeicher
  data_opa <= reg_mem(to_integer(unsigned(addr_opa)));
  data_opb <= reg_mem(to_integer(unsigned(addr_opb)));
  addr_Z <= reg_mem(31)(1 downto 0) & reg_mem(30);
  
end Behavioral;
