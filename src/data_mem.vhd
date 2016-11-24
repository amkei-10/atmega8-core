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
           data_opa     : in STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           addr_r3x     : in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";           
           sel_mux_dm   : in STD_LOGIC_VECTOR (2 downto 0) := "000";           
           sel_w_e_dm   : in STD_LOGIC_VECTOR (2 downto 0) := "000";
           
--           w_e_portb: in STD_LOGIC := '0';
--           w_e_portc: in STD_LOGIC := '0';
--           w_e_pinb : in STD_LOGIC := '0';
--           w_e_pinc : in STD_LOGIC := '0';
--           w_e_pind : in STD_LOGIC := '0';
--           w_e_dm 	: in STD_LOGIC := '0';           
                     
           data_dm      : out STD_LOGIC_VECTOR (7 downto 0) :="00000000");
end data_mem;

architecture Behavioral of data_mem is
	signal 	portb 	: std_logic_vector (7 downto 0) := "00000000"; 
	signal 	portc 	: std_logic_vector (7 downto 0) := "00000000";
	signal 	pinb  	: std_logic_vector (7 downto 0) := "00000000";
	signal 	pinc  	: std_logic_vector (7 downto 0) := "00000000";
	signal 	pind  	: std_logic_vector (7 downto 0) := "00000000";
	
	type 	memslot is array(1018 downto 0) of std_logic_vector(7 downto 0);	-- 10bit -> 1024 slots - 5 slots for ports/pins - 1
	signal 	memory:memslot := (others => (others => '0')); 
begin

	write_data: process (clk, sel_w_e_dm)
	begin
	  if clk'event and clk = '1' then  -- rising clock edge
		
		case sel_w_e_dm is 
            when write_selcode_portb => portb <= data_opa;
            when write_selcode_portc => portc <= data_opa;
            when write_selcode_pinb  => pinb <= data_opa;
            when write_selcode_pinc  => pinc <= data_opa;
            when write_selcode_pind  => pind <= pind;
            when write_selcode_dm    => memory(to_integer(unsigned(addr_r3x))) <= data_opa;
            when others => null;
        end case;
		
	  end if;
	end process write_data;

	
	process (sel_mux_dm, portb, portc, pinb, pinc, pind) is
	begin
      case sel_mux_dm is
         when read_selcode_portb => data_dm <= portb;
         when read_selcode_portc => data_dm <= portc;
         when read_selcode_pinb  => data_dm <= pinb;
         when read_selcode_pinc  => data_dm <= pinc;
         when read_selcode_pind  => data_dm <= pind;
         when others  		     => data_dm <= memory(to_integer(unsigned(addr_r3x)));
      end case;
	end process;

end Behavioral;
