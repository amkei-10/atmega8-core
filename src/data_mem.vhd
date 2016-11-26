----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2016 00:22:05
-- Design Name: 
-- Module Name: data_mem - Behavioral
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
library work;
use work.pkg_datamem.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_mem is
    Port ( clk          : in STD_LOGIC := '0';
		   reset		: in STD_LOGIC := '0';		   
           
           data_opa     : in STD_LOGIC_VECTOR (7 downto 0) := x"00";
           addr_r3x     : in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";           
           w_e_datamem   : in STD_LOGIC := '0';
           
           data_dm      : out STD_LOGIC_VECTOR (7 downto 0) :="00000000";           
           data_pinb	: out STD_LOGIC_VECTOR (7 downto 0) :="00000000";
           data_pinc	: out STD_LOGIC_VECTOR (7 downto 0) :="00000000";
           data_pind	: out STD_LOGIC_VECTOR (7 downto 0) :="00000000");
end data_mem;

architecture Behavioral of data_mem is
	--signal 	portb 	: std_logic_vector (7 downto 0) := x"00"; 
	--signal 	portc 	: std_logic_vector (7 downto 0) := x"00";
	--signal 	pinb  	: std_logic_vector (7 downto 0) := x"00";
	--signal 	pinc  	: std_logic_vector (7 downto 0) := x"00";
	--signal 	pind  	: std_logic_vector (7 downto 0) := x"00";
	
	type 	memslot is array(1023 downto 0) of std_logic_vector(7 downto 0);	-- 10bit -> 1024 slots - 5 slots for ports/pins - 1
	signal 	memory:memslot := (others => (others => '0')); 
	
	-- see portmap (was given)
	constant addr_pinb : integer := 54; -- "0x36"
	constant addr_pinc : integer := 51;	-- "0x33"
	constant addr_pind : integer := 48;	-- "0x30"
	
begin

	-- todo: reset behavior (see datasheet p.56 ... enable internal pullup, keep datamem untouched/undefined)
	write_data: process (clk, w_e_datamem)
	begin
	  if clk'event and clk = '1' then 
		if reset = '1' then
		 null;
		elsif w_e_datamem = '1' then
			memory(to_integer(unsigned(addr_r3x))) <= data_opa;
		end if;
	  end if;
	end process write_data;

	data_dm <= memory(to_integer(unsigned(addr_r3x)));	
	data_pinb <= memory(addr_pinb);
	data_pinc <= memory(addr_pinc);
	data_pind <= memory(addr_pind);	
	
end Behavioral;
