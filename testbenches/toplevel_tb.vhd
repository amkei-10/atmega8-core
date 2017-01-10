-------------------------------------------------------------------------------
-- Title      : Testbench for design "toplevel"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
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
-- Date        Version  Author  	Description
-- 2015-06-23  1.0      mkellner	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.pkg_processor.all;
-------------------------------------------------------------------------------

entity toplevel_tb is

end toplevel_tb;

-------------------------------------------------------------------------------

architecture behaviour of toplevel_tb is

  component toplevel
    port (
			clk           : in STD_LOGIC;
            
            hw_seg_enbl    : out std_logic_vector (3 downto 0) := (others => '0');
            hw_seg_cont    : out std_logic_vector (7 downto 0) := (others => '0');
            
            hw_portb    : out std_logic_vector (7 downto 0) := (others => '0');
            hw_portc    : out std_logic_vector (7 downto 0) := (others => '0');
            
            hw_pinb        : in std_logic_vector (7 downto 0) := (others => '0');
            hw_pinc        : in std_logic_vector (7 downto 0) := (others => '0');
            hw_pind        : in std_logic_vector (4 downto 0) := (others => '0') 
      );
  end component;

  -- component ports
	signal clk     : STD_LOGIC:='0';
	signal pinb	   : std_logic_vector (7 downto 0):="00000000";
	signal pinc	   : std_logic_vector (7 downto 0):="00000000";
	signal pind	   : std_logic_vector (4 downto 0):="00000";
	signal portb   : std_logic_vector (7 downto 0):="00000000";
	signal portc   : std_logic_vector (7 downto 0):="00000000";
    signal seg_enbl: std_logic_vector (3 downto 0) := (others => '0');
    signal seg_cont: std_logic_vector (7 downto 0) := (others => '0');

begin  -- behaviour

  -- component instantiation
  DUT: toplevel
    port map (
      clk   => clk,
      hw_portb => portb,
      hw_portc => portc,
      hw_pinb  => pinb,
      hw_pinc  => pinc,
      hw_pind  => pind,
      hw_seg_enbl => seg_enbl,
      hw_seg_cont => seg_cont);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    
    --reset
    pind <= "11111";
    pinb <= "01010101";
	pinc <= "00001111";
    wait for 20ns;
    
    pind <= "00000";
    
	
    wait;

  end process WaveGen_Proc;

  

end behaviour;

-------------------------------------------------------------------------------

configuration toplevel_tb_behaviour_cfg of toplevel_tb is
  for behaviour
  end for;
end toplevel_tb_behaviour_cfg;

-------------------------------------------------------------------------------
