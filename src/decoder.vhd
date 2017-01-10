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
    state_sreg	: in  std_logic_vector(7 downto 0) 	:= (others => '0');	-- SREG
    addr_opa    : out std_logic_vector(4 downto 0) 	:= (others => '0'); -- Adresse von 1. Operand
    addr_opb    : out std_logic_vector(5 downto 0) 	:= (others => '0'); -- Adresse von 2. Operand
    data_dcd  	: out std_logic_vector(7 downto 0) 	:= (others => '0'); -- Immediate Value
    OPCODE      : out std_logic_vector(4 downto 0) 	:= (others => '0'); -- Opcode für ALU
    w_e_regf 	: out bit;    											-- write enable for Registerfile
    --w_e_mem		: out bit;    											-- write enable for Datamemory
    mask_sreg   : out std_logic_vector(7 downto 0) 	:= (others => '0'); -- SREG bitmask for write_enables
	rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0) := (others => '0');	-- jump (program_counter)
    abs_jmp		: out bit;        							-- relative/absolute jmp
    --sel_im		: out std_logic := '0';        							-- Mux-Selecteingang für im-data (ALU)
    mdec_op		: out std_logic_vector(2 downto 0);							-- [3]toggle, [2]w_e, [1]push, [0]pop
    sel_ldi 	: out bit;
    sel_alu		: out bit;
    sel_opb		: out bit_vector(2 downto 0);	-- 000: opb, 001:nopb, 010:dcd, 110: ndcd, 011:0
    sel_bconst	: out bit_vector(1 downto 0);	-- 00: 0, 	 01:1, 	   10:-1,   11:carry
    sel_maddr	: out bit
    );
end decoder;

architecture Behavioral of decoder is
begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_regf, mask_sreg, ...
  dec_mux: process (Instr, state_sreg)
	variable mdec_op_tmp : std_logic_vector(2 downto 0) := (others => '0');
  begin  -- process dec_mux

    --prevent latches
    OPCODE <= op_NOP;
    mask_sreg <= (others => '0');
    
	rel_pc <= (others => '0');
	addr_opa <= Instr(8 downto 4);
    addr_opb <= "0"&Instr(9) & Instr (3 downto 0);
    sel_maddr <= '0';
    
    --control pins
    abs_jmp <= '0';
    sel_ldi <= '0';
    sel_alu <= '1';
    w_e_regf <= '0';
    
    --sel_im <= '0';
    sel_opb <= "000";    
    sel_bconst <= "00";
    
    mdec_op_tmp := (others => '0');
    
	-- SREG: [I][T][H][S][V][N][Z][C]
    case Instr(15 downto 10) is    
	  
      -- ADD: Adds two registers without the C Flag and places the result in the destination register Rd.
      -- LSL: Shifts all bits in Rd one place to the left. Bit 0 is cleared. Bit 7 is loaded into the C Flag of the SREG.       
      when "000011" =>        
        OPCODE <= op_add;
        w_e_regf <= '1';
        mask_sreg <= "00111111";
        
      -- SUB: Subtracts two registers and places the result in the destination register Rd.
      when "000110" =>
        OPCODE <= op_sub;
        w_e_regf <= '1';
        mask_sreg <= "00111111";
        sel_opb <= "001";
        sel_bconst <= "01";
      
      -- CP: This instruction performs a compare between two registers Rd and Rr. None of the registers are changed.
      when "000101" =>
        OPCODE <= op_sub;
        mask_sreg <= "00111111";
      
      -- ROL: Shifts all bits in Rd one place to the left. The C Flag is shifted into bit 0 of Rd. Bit 7 is shifted into the C Flag. 
      -- ADC: Adds two registers and the contents of the C Flag and places the result in the destination register Rd.
      when "000111" =>
        OPCODE <= op_adc;
        w_e_regf <= '1';
        mask_sreg <= "00111111";
        sel_bconst <= "11";
      
      -- AND: Performs the logical AND between register Rd and register Rr, and places the result in the destination register Rd.
	  when "001000" =>
        OPCODE <= op_and;
        w_e_regf <= '1';
        mask_sreg <= "00011110";
      
      -- EOR 
      when "001001" =>
        OPCODE <= op_eor;
        w_e_regf <= '1';
        mask_sreg <= "00011110";
        
      -- MOV
	  when "001011" =>
        OPCODE <= op_mov;
        w_e_regf <= '1';
 
      
      when "100000" =>
		
		-- Load(LD/LDD) : 	1000 000d dddd 0000
		-- Store(ST/STD) : 	1000 001r rrrr 0000
		if Instr(3 downto 0) = "0000" then
			sel_alu <= to_bit(Instr(9));
			w_e_regf <= not to_bit(Instr(9));
			mdec_op_tmp(2) := Instr(9);
		end if;
		
      --branch commandset A
	  when "111101" =>
		case Instr (2 downto 0) is 				
			-- brcc ( Branch if Carry Cleared)
			when "000" => 
				if state_sreg(0) = '0' then
					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
				end if;				
			-- brne ( Branch if Not Equal)
			when "001" => 
				if state_sreg(1) = '0' then
					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
				end if;				
			when others => null;		
		end case;

	  --branch commandset B
	  when "111100" =>
		case Instr (2 downto 0) is 
			
			-- breq ( Branch if Equal)
			when "001" => 
				if state_sreg(1) = '1' then
					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
				end if;
			
			-- brcs ( branch if carry set )	
			when "000" => 
				if state_sreg(0) = '1' then
					rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
				end if;
			
			when others => null;
		end case;	
			
		
      when "100101" =>
		w_e_regf <= '1';
		
		-- 1001 01bx xxxx bbbb
		case Instr(9) & Instr(3 downto 0) is		
			-- COM: performs a One’s Complement of register Rd
			when "00000" =>
			  OPCODE <= op_com;	
			  mask_sreg <= "00011111";
			  
			-- ASR: Arithmetic Shift Right
			when "00101" =>
			  OPCODE <= op_asr;
			  mask_sreg <= "00011111";			  
			  
			-- DEC
			when "01010" =>
			  OPCODE <= op_dec;
			  mask_sreg <= "00011110";
			  sel_opb <= "011";
			  sel_bconst <= "10";
			  
			-- INC
			when "00011" =>
			  OPCODE <= op_inc;
			  mask_sreg <= "00011110";
			  sel_opb <= "011";
			  sel_bconst <= "01";
			  
			-- LSR
			when "00110" =>
				OPCODE <= op_lsr;
				mask_sreg <= "00011111";
		
			-- RET
			when "01000" =>
				if Instr(8 downto 4) = "10000" then
					abs_jmp <= '1';
					w_e_regf <= '0';
					sel_alu <= '0';
					mdec_op_tmp := mdec_op_ret;
				end if;

			when others => w_e_regf <= '0';
		end case;
		
	  
	  --PUSH: 1001 001d dddd 1111
	  --POP	: 1001 000d dddd 1111
	  when "100100" =>		  
		if Instr(3 downto 0) = "1111" then
			mdec_op_tmp := Instr(9) & Instr(9) & not Instr(9);
			w_e_regf <= not to_bit(Instr(9));
			sel_alu <= '0';
		end if;
	  	
		
      -- immediate + rel commands + in/out
      when others =>
        --sel_im <= '1';
        sel_opb <= "010";
        addr_opa <= '1' & Instr(7 downto 4);    
        
        case Instr(15 downto 12) is 
		  
		  -- LDI
          when "1110" =>
            OPCODE <= op_nop;
            sel_ldi <= '1';
            w_e_regf <= '1';
            
          -- CPI
          when "0011" =>
            OPCODE <= op_sub;
            mask_sreg <= "00111111";
            sel_opb <= "110";
            sel_bconst <= "01";
            
          -- SUBI
          when "0101" =>
            OPCODE <= op_sub;
            mask_sreg <= "00111111";
            w_e_regf <= '1';
            sel_opb <= "110";
            sel_bconst <= "01";
                        
          -- ORI
          when "0110" =>
			OPCODE <= op_or;
			mask_sreg <= "00011110";
            w_e_regf <= '1';
            			
          -- ANDI
          when "0111" =>
            OPCODE <= op_and;
            mask_sreg <= "00011110";
            w_e_regf <= '1';
                      
          -- RJMP
          when "1100" =>  
			rel_pc <= Instr(8 downto 0);			
            
          -- RCALL
          when "1101" =>
			rel_pc <= Instr(8 downto 0);
			mdec_op_tmp := mdec_op_rcall;
        
		  --OUT:1011 1AAr rrrr AAAA : Stores data from register Rr in the Register File to I/O Space
		  --IN:	1011 0AAd dddd AAAA : Loads data from the I/O Space into register Rd in the Register File.
          when "1011" => 
		    addr_opa <= Instr(8 downto 4);
		    -- in/out addr-operant    
			addr_opb <= Instr(10 downto 9)&Instr(3 downto 0);
			sel_maddr <= '1';
			sel_alu <= '0';        
			w_e_regf <= not to_bit(Instr(11));
			mdec_op_tmp := Instr(11) & "00";
		  when others => null;
		end case;
    end case;
    
    mdec_op <= mdec_op_tmp;

  end process dec_mux;
  
  data_dcd <=  Instr(11 downto 8)&Instr(3 downto 0);

end Behavioral;
