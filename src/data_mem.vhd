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
    Port ( clk      : in STD_LOGIC;
		   reset	: in STD_LOGIC;           
           data_in	: in STD_LOGIC_VECTOR (7 downto 0);
           addr_r3x : in STD_LOGIC_VECTOR (9 downto 0);           
           w_e      : in STD_LOGIC := '0';
           push		: in std_logic;
		   pop		: in std_logic;
		   data_out : out STD_LOGIC_VECTOR (7 downto 0));
end data_mem;

architecture Behavioral of data_mem is
	
	type 	memslot is array(1023 downto 0) of std_logic_vector(7 downto 0);	-- 10bit -> 1024 slots - 5 slots for ports/pins - 1
	signal 	memory:memslot := (others => (others => '0')); 
	
	signal 	stack_ptr : std_logic_vector (9 downto 0) := "0000000000";
	
begin

	-- todo: reset behavior (see datasheet p.56 ... enable internal pullup, keep datamem untouched/undefined)
	write_data: process (clk, w_e, data_in)
	begin
	  if clk'event and clk = '1' then 
		if reset = '1' then
			memory <= (others => "00000000");
		elsif w_e = '1' then
			memory(to_integer(unsigned(addr_r3x))) <= data_in;
		end if;
				
	  end if;
	end process write_data;

	data_out <= memory(to_integer(unsigned(addr_r3x)));	
	
	push_stack:process(clk, push, data_in )
	begin
		if clk'event and clk = '1' and push = '1' then
			memory(to_integer(unsigned(stack_ptr))) <= data_in;
			stack_ptr<=std_logic_vector(unsigned(stack_ptr)-1);
		end if;
	end process;
	
end Behavioral;
