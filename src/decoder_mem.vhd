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
use IEEE.NUMERIC_STD.ALL;
use work.pkg_processor.ALL;	-- definitions of selection-codes

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_mem is
    Port ( 	w_e_out		: out bit;			
			addr_in 	: in STD_LOGIC_VECTOR (9 downto 0);
			addr_out	: out STD_LOGIC_VECTOR (9 downto 0);
			ram_en		: out bit;
			sel_mdec	: out bit;
			mdec_op		: in std_logic_vector(3 downto 0));
end decoder_mem;


architecture Behavioral of decoder_mem is
	--signal 	stack_ptr : unsigned(9 downto 0) := (others => '1');
begin

	--memptr_config:process(trigger, addr_in, w_e_in, push, pop)
	memptr_config:process(mdec_op, addr_in)
		variable stack_ptr : unsigned(9 downto 0) := (others => '1');
	begin
		
		ram_en <= '1';
			
		case mdec_op(2 downto 0) is 
					
			--PUSH stores the contents of register Rr on the STACK. The Stack Pointer is post-decremented by 1 after the PUSH.
			--PUSH + RCALL
			when mdec_op_rcall | mdec_op_push => 
				addr_out <= std_logic_vector(stack_ptr);
				stack_ptr := stack_ptr-1;
							
			--POP loads register Rd with a byte from the STACK. The Stack Pointer is pre-incremented by 1 before the POP.
			--POP + RET
			when mdec_op_ret | mdec_op_pop =>
				if not (stack_ptr = "1111111111") then
					stack_ptr := stack_ptr+1;
					addr_out <= std_logic_vector(stack_ptr);						
				else
					addr_out <= std_logic_vector(stack_ptr);
				end if;
					
			when others => 
				ram_en <= '0';
			
				case addr_in(9 downto 0) is		
			
					when def_addr_pinb =>	addr_out <= (9 downto 4 => '0')&"0000";
					when def_addr_pinc =>	addr_out <= (9 downto 4 => '0')&"0001";
					when def_addr_pind =>	addr_out <= (9 downto 4 => '0')&"0010";
					when def_addr_portb =>	addr_out <= (9 downto 4 => '0')&"0011";
					when def_addr_portc =>	addr_out <= (9 downto 4 => '0')&"0100";
					when def_addr_segen =>	addr_out <= (9 downto 4 => '0')&"0101";
					when def_addr_seg0 =>	addr_out <= (9 downto 4 => '0')&"0110";
					when def_addr_seg1 =>	addr_out <= (9 downto 4 => '0')&"0111";
					when def_addr_seg2 =>	addr_out <= (9 downto 4 => '0')&"1000";
					when def_addr_seg3 =>	addr_out <= (9 downto 4 => '0')&"1001";

					when others =>
						ram_en <= '1';
						addr_out <= addr_in;
				end case;	
		end case;		
	end process;

	sel_mdec <= to_bit(mdec_op(1) and mdec_op(0));	-- push & pop
	w_e_out <= to_bit(mdec_op(2));					-- w_e
	
end Behavioral;
