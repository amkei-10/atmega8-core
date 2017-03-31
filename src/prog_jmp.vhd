----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:30:37 PM
-- Design Name: 
-- Module Name: prog_cnt - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_processor.all;


entity prog_jmp is
  port (
		signal	opcode 		: in std_logic_vector(2 downto 0) := (others => '0');
		signal	state_sreg	: in std_logic_vector(2 downto 0);
		signal	jmpcode_in	: in std_logic_vector(1 downto 0);
		signal	jmpcode_out	: out std_logic_vector(1 downto 0) := jmp_code_inc;
		signal 	flush_instr	: out std_logic	:= '0'
    );
end prog_jmp;


architecture Behavioral of prog_jmp is
begin

	set_rel_pm:process(opcode, jmpcode_in, state_sreg)		
	begin
		
		flush_instr <= '0';
		jmpcode_out <= jmpcode_in;
		
		-- if relative OR absolute jump
		if jmpcode_in(1) = '1' then
			
			case opcode is
				
				-- brcc
				when op_add(2 downto 0) => 
					flush_instr <= not state_sreg(0);					--jump if state_sreg(0) = '0'
					jmpcode_out <= not state_sreg(0) & state_sreg(0);
				
				-- brne
				when op_sub(2 downto 0)  => 
					flush_instr <= not state_sreg(1);					--jump if state_sreg(1) = '0'
					jmpcode_out <= not state_sreg(1) & state_sreg(1);
				
				-- brcs
				when op_or(2 downto 0)  => 
					flush_instr <= state_sreg(0);						--jump if state_sreg(0) = '1'
					jmpcode_out <= state_sreg(0) & not state_sreg(0);
				
				-- breq
				when op_dec(2 downto 0)  => 
					flush_instr <= state_sreg(1);						--jump if state_sreg(1) = '1'
					jmpcode_out <= state_sreg(1) & not state_sreg(1);
				
				-- rjmp, rcall
				when op_adc(2 downto 0) | op_and(2 downto 0) | op_eor(2 downto 0) => 
					flush_instr <= '1';
				
				when others => jmpcode_out <= jmp_code_inc;
			end case;
			
		end if;
		
	end process;

end Behavioral;
