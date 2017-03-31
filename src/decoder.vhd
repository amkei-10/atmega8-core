-------------------------------------------------------------------------------
-- Title      : decoder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : decoder.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2015-06-25
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
library work;
use work.pkg_processor.all;

-------------------------------------------------------------------------------

entity decoder is
  port (
    Instr       : in  std_logic_vector(15 downto 0)	:= (others => '0'); -- Eingang vom Programmspeicher
    addr_opa    : out std_logic_vector(4 downto 0) 	:= (others => '0'); -- Adresse von 1. Operand
    addr_opb    : out std_logic_vector(5 downto 0) 	:= (others => '0'); -- Adresse von 2. Operand (6bit @see in/out)
    data_opim  	: out std_logic_vector(7 downto 0) := (others => '0'); -- Immediate Value
    OPCODE      : out std_logic_vector(4 downto 0) 	:= (others => '0'); -- Opcode f??r ALU
    w_e_regf 	: out bit;    											-- write enable for Registerfile
    --mask_sreg   : out std_logic_vector(7 downto 0) 	:= (others => '0'); -- SREG bitmask for write_enables
    mask_sreg   : out std_logic_vector(2 downto 0) 	:= (others => '0'); -- SREG bitmask for write_enables
	--rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0');	-- jump (program_counter)
    jmpcode		: out std_logic_vector(1 downto 0);							-- "00":not used "01":inc "10":rel "11":abs
    mdec_op		: out std_logic_vector(2 downto 0);							-- [2]w_e, [1]push, [0]pop
    sel_opb		: out bit;
    sel_alu		: out bit;
    sel_Zaddr	: out bit
    );
end decoder;

architecture Behavioral of decoder is
begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_regf, mask_sreg, ...
  dec_mux: process (Instr)
  begin  -- process dec_mux

    --prevent latches
    OPCODE <= op_nop;
    mask_sreg <= (others => '0');
    
	--rel_pc <= "000000001";		--used as latch
	jmpcode <= jmp_code_inc;
	addr_opa <= Instr(8 downto 4);
    addr_opb <= "0"&Instr(9) & Instr (3 downto 0);
    sel_Zaddr <= '1';
    
    --control pins
    sel_opb <= '1';
    sel_alu <= '1';
    w_e_regf <= '0';
    
    mdec_op <=  (others => '0');
    
	-- SREG: [I][T][H][S][V][N][Z][C]
    case Instr(15 downto 10) is    
	  
      -- ADD: Adds two registers without the C Flag and places the result in the destination register Rd.
      -- LSL: Shifts all bits in Rd one place to the left. Bit 0 is cleared. Bit 7 is loaded into the C Flag of the SREG.       
      when "000011" =>        
        OPCODE <= op_add;
        w_e_regf <= '1';
        mask_sreg <= "111";
        
      -- SUB: Subtracts two registers and places the result in the destination register Rd.
      when "000110" =>
        OPCODE <= op_sub;
        w_e_regf <= '1';
        mask_sreg <= "111";
      
      -- CP: This instruction performs a compare between two registers Rd and Rr. None of the registers are changed.
      when "000101" =>
        OPCODE <= op_sub;
        mask_sreg <= "111";
      
      -- ROL: Shifts all bits in Rd one place to the left. The C Flag is shifted into bit 0 of Rd. Bit 7 is shifted into the C Flag. 
      -- ADC: Adds two registers and the contents of the C Flag and places the result in the destination register Rd.
      when "000111" =>
        OPCODE <= op_adc;
        w_e_regf <= '1';
        mask_sreg <= "111";
      
      -- AND: Performs the logical AND between register Rd and register Rr, and places the result in the destination register Rd.
	  when "001000" =>
        OPCODE <= op_and;
        w_e_regf <= '1';
		mask_sreg <= "110";
		
      -- EOR 
      when "001001" =>
        OPCODE <= op_eor;
        w_e_regf <= '1';
        mask_sreg <= "110";
      
      -- OR 
      when "001010" =>
        OPCODE <= op_or;
        w_e_regf <= '1';
        mask_sreg <= "110";
        
      -- MOV
	  when "001011" =>
        OPCODE <= op_mov;
        w_e_regf <= '1';
 
      
      when "100000" =>
		
		-- Load(LD/LDD) : 	1000 000d dddd 0000 (w_e_rf)
		-- Store(ST/STD) : 	1000 001r rrrr 0000 (w_e_dm)
		if Instr(3 downto 0) = "0000" then
			sel_alu <= '0';
			w_e_regf <= not to_bit(Instr(9));
			mdec_op <= '1' & Instr(9) & '0';
			--sel_opb <= '0';			
		end if;
		
	  -- branch: 1111 0?ll llll l00?
	  -- lead data over addrA and opim wires
	  when "111101" | "111100" =>
		sel_opb <= '0';					--disbale forwarding in IF
		jmpcode <= jmp_code_rel;
		--rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
		case Instr(10) & Instr(2 downto 0) is
			-- brcc ( Branch if Carry Cleared)
			when "1000" => OPCODE <= op_add;	
			-- brne ( Branch if Not Equal)
			when "1001" => OPCODE <= op_sub;
			-- brcs ( branch if carry set )
			when "0000" => OPCODE <= op_or;
			-- breq ( Branch if Equal)
			when "0001" => OPCODE <= op_dec;
			when others => jmpcode <= jmp_code_inc;
		end case;
		
	  --branch commandset A
	  --todo: brbs / brcs      
--	  when "111101" =>
--		case Instr (2 downto 0) is			
--			-- brcc ( Branch if Carry Cleared)
--			when "000" => 
--				--if state_sreg(0) = '0' then
--					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
--					jmpcode <= jmp_code_rel;
--				--end if;				
--			-- brne ( Branch if Not Equal)
--			when "001" => 
--				--if state_sreg(1) = '0' then
--					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
--					jmpcode <= jmp_code_rel;
--				--end if;				
--			when others => null;		
--		end case;

	  --branch commandset B
--	  when "111100" =>
--		case Instr (2 downto 0) is 
--			
--			-- breq ( Branch if Equal)
--			when "001" => 
--				--if state_sreg(1) = '1' then
--					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
--					jmpcode <= jmp_code_rel;
--				--end if;
--
--			-- brcs ( branch if carry set )
--			when "000" => 
--				--if state_sreg(0) = '1' then
--					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
--					jmpcode <= jmp_code_rel;
--				--end if;
--			
--			when others => null;
--		end case;	
			
		
      when "100101" =>
		w_e_regf <= '1';
		addr_opb <= "0"&Instr(8 downto 4);
		
		-- 1001 01bx xxxx bbbb
		case Instr(9) & Instr(8) & Instr(3 downto 0) is		
			-- COM: performs a One???s Complement of register Rd
			when "000000" | "010000" =>
			  OPCODE <= op_com;	
			  mask_sreg <= "111";
			  
			-- ASR: Arithmetic Shift Right
			when "010101" | "000101" =>
			  OPCODE <= op_asr;
			  mask_sreg <= "111";
			  
			-- DEC
			-- todo: convert into subi with opim=00000001
			when "011010" | "001010"=>
			  OPCODE <= op_dec;
			  mask_sreg <= "110";
			  
			-- INC
			-- todo: convert into subi with opim=11111111
			when "010011" | "000011"=>
			  OPCODE <= op_inc;
			  mask_sreg <= "110";
			  
			-- LSR
			when "010110" | "000110" =>
				OPCODE <= op_lsr;
				mask_sreg <= "111";
		
			-- RET
			when "011000" =>
				w_e_regf <= '0';
				sel_alu <= '0';
				mdec_op <= mdec_op_pop;
				jmpcode <= jmp_code_abs;
				OPCODE <= op_eor;

			-- SEC & CLC
			when "001000" => 
				OPCODE <= "111" & Instr(7) & Instr(7);	--@see pkg_processor.vhd
				mask_sreg <= "001";				
				w_e_regf <= '0';
				
			when others => w_e_regf <= '0';
		end case;
		
	  
	  --PUSH: 1001 001d dddd 1111 	(w_e_dm)
	  --POP	: 1001 000d dddd 1111	(w_e_rf)
	  when "100100" =>		  
		if Instr(3 downto 0) = "1111" then
			mdec_op <= '0' & Instr(9) & not Instr(9);
			w_e_regf <= not to_bit(Instr(9));
			sel_alu <= '0';
			sel_opb <= '0';
		end if;
	  	
		
      -- immediate + rel commands + in/out
      when others =>
        addr_opa <= '1' & Instr(7 downto 4);    						-- MSB = offset for im-commands (r16...r31)
        sel_opb <= '0';
        w_e_regf <= '1';
         
        case Instr(15 downto 12) is 
		  
		  -- LDI
          when "1110" =>
            OPCODE <= op_mov;                       
            
          -- CPI
          when "0011" =>
            OPCODE <= op_sub;
            mask_sreg <= "111"; 
            w_e_regf <= '0';
            
          -- SUBI
          when "0101" =>
            OPCODE <= op_sub;
            mask_sreg <= "111";
                        
          -- ORI
          when "0110" =>
			OPCODE <= op_or;
			mask_sreg <= "110";
            			
          -- ANDI
          when "0111" =>
            OPCODE <= op_and;
            mask_sreg <= "110";
                      
          -- RJMP
          when "1100" =>  
			OPCODE <= op_adc;
			--rel_pc <= Instr(8 downto 0);
            jmpcode <= jmp_code_rel;
            w_e_regf <= '0';
            
          -- RCALL
          when "1101" =>
			OPCODE <= op_and;
			--rel_pc <= Instr(8 downto 0);
			mdec_op <= mdec_op_rcall;
			jmpcode <= jmp_code_rel;
			w_e_regf <= '0';
        
		  --OUT:1011 1AAr rrrr AAAA : Stores data from register Rr to I/O Space
		  --IN:	1011 0AAd dddd AAAA : Loads data from the I/O Space into register Rd
          when "1011" => 
		    addr_opa <= Instr(8 downto 4);
		    -- in/out addr-operant    
			addr_opb(5) <= Instr(10);
			sel_Zaddr <= '0';
			sel_alu <= '0';        
			w_e_regf <= not to_bit(Instr(11));
			mdec_op <= '0' & Instr(11) & not Instr(11);
			--sel_opb <= '1';
		  
		  when others => null;
		end case;
    end case;
    
  end process dec_mux;
  
  -- 11:0 			-> rjmp + rcall
  -- 11:8 & 3:0		-> ldi, cpi, subi, ori, andi
  -- 9:3			-> branch
  data_opim <= Instr(11 downto 8) & Instr(3 downto 0);

end Behavioral;
