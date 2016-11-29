----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2016 22:26:49
-- Design Name: 
-- Module Name: decoder_mem - Behavioral
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
use work.pkg_datamem.ALL;	-- definitions of selection-codes

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_mem is
    Port ( 	addr_r3x 	: in STD_LOGIC_VECTOR (9 downto 0) := "0000000000";		
			w_e_memory	: in std_logic;
			sel_memory	: out std_logic_vector(3 downto 0);
			w_e_portb	: out std_logic;
			w_e_portc	: out std_logic;
			w_e_dm		: out std_logic;
			w_e_segen	: out std_logic;
		    w_e_seg0	: out std_logic;
		    w_e_seg1	: out std_logic;
		    w_e_seg2	: out std_logic;
		    w_e_seg3	: out std_logic);
end decoder_mem;


architecture Behavioral of decoder_mem is
    signal selector:std_logic_vector(3 downto 0);
begin

	-- selection for memory-output-multiplexer
	memory_selection:process (addr_r3x)
	begin	
		case addr_r3x(7 downto 0) is		
			
			--pinb/c/d
			when def_addr_pinb =>
				selector <= selcode_mem_pinb;
			when def_addr_pinc =>
				selector <= selcode_mem_pinc;
			when def_addr_pind =>
				selector <= selcode_mem_pind;
			
			-- portb/c
			when def_addr_portb =>
				selector <= selcode_mem_portb;
			when def_addr_portc =>
				selector <= selcode_mem_portc;
			
			-- 7 segment
			when def_addr_segen =>
				selector <= selcode_mem_segen;
			when def_addr_seg0 =>
				selector <= selcode_mem_seg0;
			when def_addr_seg1 =>
				selector <= selcode_mem_seg1;			
			when def_addr_seg2 =>
				selector <= selcode_mem_seg2;
			when def_addr_seg3 =>
				selector <= selcode_mem_seg3;
			
			-- data memory
			when others =>
				selector <= selcode_mem_dm;				
		end case;				
	end process;


	--select w_e_wire to related memory
	select_memory_w_e:process(selector, w_e_memory)
	begin
		w_e_portb <= '0';
		w_e_portc <= '0';
		w_e_dm <= '0';
		w_e_segen <= '0';
		w_e_seg0 <= '0';
		w_e_seg1 <= '0';
		w_e_seg2 <= '0';
		w_e_seg3 <= '0';
		if w_e_memory = '1' then
			case selector is
				when selcode_mem_portb =>
					w_e_portb <= '1';
				when selcode_mem_portc =>
					w_e_portc <= '1';
				when selcode_mem_segen =>
					w_e_segen <= '1';
				when selcode_mem_seg0 =>
					w_e_seg0 <= '1';
				when selcode_mem_seg1 =>
					w_e_seg1 <= '1';
				when selcode_mem_seg2 =>
					w_e_seg2 <= '1';
				when selcode_mem_seg3 =>
					w_e_seg3 <= '1';
				when selcode_mem_dm =>
					w_e_dm <= '1';					
				when others => null;
			end case;
		end if;
	end process;

	sel_memory <= selector;

end Behavioral;
