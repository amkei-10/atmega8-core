-------------------------------------------------------------------------------
-- Title      : Testbench for design "prog_mem"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : prog_mem_tb.vhd
-- Author     : Burkart Voss  <bvoss@Troubadix>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2015-06-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-06-23  1.0      bvoss	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity prog_mem_tb is

end prog_mem_tb;

-------------------------------------------------------------------------------

architecture test of prog_mem_tb is

  component prog_mem
    port (
      Addr  : in  STD_LOGIC_VECTOR (8 downto 0);
      Instr : out STD_LOGIC_VECTOR (15 downto 0));
  end component;

  -- component ports
  signal Addr  : STD_LOGIC_VECTOR (8 downto 0) := "000000000";
  signal Instr : STD_LOGIC_VECTOR (15 downto 0);


begin  -- test

  -- component instantiation
  DUT: prog_mem
    port map (
      Addr  => Addr,
      Instr => Instr);

  -- clock generation
  Addr <= std_logic_vector(unsigned(Addr) + 1) after 10 ns;


end test;

-------------------------------------------------------------------------------

configuration prog_mem_tb_test_cfg of prog_mem_tb is
  for test
  end for;
end prog_mem_tb_test_cfg;

-------------------------------------------------------------------------------
