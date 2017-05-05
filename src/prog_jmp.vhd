-------------------------------------------------------------------------------
-- Title      : Jump Decoder, SREG
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : prog_jmp.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.pkg_processor.all;


entity prog_jmp is
  port (
		signal	opcode 		: in std_logic_vector(1 downto 0) 	:= (others => '0');
		signal	state_alu	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		signal	mask_sreg	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		signal	sreg_curr	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		signal	sreg_new	: out std_logic_vector(1 downto 0) 	:= (others => '0');
		signal	jmpcode_in	: in std_logic_vector(1 downto 0) 	:= jmpCode_inc;
		signal	jmpcode_out	: out std_logic_vector(1 downto 0) 	:= jmpCode_inc
    );
end prog_jmp;


architecture Behavioral of prog_jmp is
begin

	calc_sreg : process(mask_sreg, state_alu, sreg_curr)		
	begin
		sreg_new <= (state_alu and mask_sreg) or (sreg_curr and not mask_sreg);	
	end process;


	exec_branch:process(opcode, jmpcode_in, sreg_curr)
		variable cmp : std_logic_vector(3 downto 0);
	begin
		
		cmp := opcode & jmpcode_in;		
			
		case cmp is
				
			-- brcc : jump if sreg_curr(0) = '0'
			when op_lsr(1 downto 0) & jmpCode_relBranch => 
				jmpcode_out <= sreg_curr(0) & not sreg_curr(0);
				
			-- brne : jump if sreg_curr(1) = '0'
			when op_and(1 downto 0) & jmpCode_relBranch  => 
				jmpcode_out <= sreg_curr(1) & not sreg_curr(1);
				
			-- brcs : jump if sreg_curr(0) = '1'
			when op_or(1 downto 0) & jmpCode_relBranch  => 
				jmpcode_out <= not sreg_curr(0) & sreg_curr(0);
				
			-- breq : jump if sreg_curr(1) = '1'
			when op_add(1 downto 0) & jmpCode_relBranch  => 
				jmpcode_out <= not sreg_curr(1) & sreg_curr(1);
			
			--swap bits for no-conditional jumps (no effect for inc = "11")
			when others => 
				jmpcode_out(1) <= jmpcode_in(0);
				jmpcode_out(0) <= jmpcode_in(1);
					
		end case;
		
	end process;

end Behavioral;
