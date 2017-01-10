-------------------------------------------------------------------------------
-- Title      : Testbench for design "data_mem"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_mem_tb.vhd
-- Author     : Mario Kellner  <bvoss@Troubadix>
-- Company    : 
-- Created    : 2017-01-01
-- Last update: 2017-01-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  	Description
-- 2017-01-01  1.0      mkellner	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_processor.all;

-------------------------------------------------------------------------------

entity data_mem_tb is

end data_mem_tb;

-------------------------------------------------------------------------------

architecture test of data_mem_tb is

  component data_mem
    port (
			clk 	: in STD_LOGIC;
			mdec_op	: in std_logic_vector(2 downto 0);
			addr_in : in STD_LOGIC_VECTOR (9 downto 0);
			data_in	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
			data_out : out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
			pinb : in STD_LOGIC_VECTOR (7 downto 0);
			pinc : in STD_LOGIC_VECTOR (7 downto 0);
			pind : in STD_LOGIC_VECTOR (4 downto 0);           
			portb : out STD_LOGIC_VECTOR (7 downto 0);
			portc : out STD_LOGIC_VECTOR (7 downto 0);         
			segen : out STD_LOGIC_VECTOR (3 downto 0);
			segcont : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

  -- component ports
	signal clk : std_logic := '0';
	signal mdec_op	: std_logic_vector(2 downto 0):= (others => '0');
	signal addr_in : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
	signal data_in	: STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal data_out : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal pinb : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal pinc : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal pind : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
	signal portb : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal portc : STD_LOGIC_VECTOR (7 downto 0) := (others => '0'); 
	signal segen : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal segcont : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin  -- test

  -- component instantiation
  DUT: data_mem
    port map (
      clk  => clk,
      mdec_op => mdec_op,      
      addr_in => addr_in,
      data_in => data_in,
      data_out => data_out,
      pinb => pinb,
      pinc => pinc,
      pind => pind,
      portb => portb,
      portc => portc,
      segen => segen,
      segcont => segcont);

  -- clock generation
	clk <= not clk after 10 ns;

	process
	begin
		
		--Initialisierung
		mdec_op <= "000";
		pinb <= "10000001";
		pinc <= "01000010";
		pind <= "10001";
		wait for 40ns;		
		
		-- SFR beschreiben
		data_in <= "011110000";
		addr_in <= "00"&x"36";
		mdec_op(2) <= '1';	
		wait for 20ns;
		
		-- ordinären memoryslot beschreiben
		addr_in <= "00"&x"37";
		wait for 20ns;
		
		-- SFR lesen
		addr_in <= "00"&x"36";
		mdec_op(2) <= '0';	
		wait for 20ns;
		
		-- ordinären memoryslot beschreiben
		addr_in <= "00"&x"37";
		wait for 20ns;

		--push
		mdec_op <= mdec_op_push;
		wait for 20ns;
		
		--pop
		mdec_op <= mdec_op_pop;
		wait for 20ns;
				
		--rcall
		mdec_op <= mdec_op_rcall;
		addr_in <= "00"&x"01";	-- set dummy addr
		data_in <= "0"&x"AA";
		wait for 20ns;
		
		--ret
		mdec_op <= mdec_op_ret;
		wait for 20ns;
		 
		mdec_op <= "000"; 
		wait;
		
	end process;

end test;

-------------------------------------------------------------------------------

configuration data_mem_tb_test_cfg of data_mem_tb is
  for test
  end for;
end data_mem_tb_test_cfg;

-------------------------------------------------------------------------------
