-------------------------------------------------------------------------------
-- Title      : decoder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : decoder.vhd
-- Author     : Burkart Voss  <bvoss@Troubadix>
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
-- Date        Version  Author  Description
-- 2015-06-23  1.0      bvoss	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.pkg_processor.all;

-------------------------------------------------------------------------------

entity decoder is
  port (
    Instr       : in  std_logic_vector(15 downto 0) := "0000000000000000";  	-- Eingang vom Programmspeicher
    state_sreg	: in  std_logic_vector(7 downto 0) := "00000000";				-- SREG
    addr_opa    : out std_logic_vector(4 downto 0) := "00000";   				-- Adresse von 1. Operand
    addr_opb    : out std_logic_vector(4 downto 0) := "00000";   				-- Adresse von 2. Operand
    data_dcd  	: out std_logic_vector(7 downto 0) := "00000000";  				-- Immediate Value
    OPCODE      : out std_logic_vector(4 downto 0) := "00000";   				-- Opcode für ALU
    w_e_regfile : out std_logic := '0';    										-- write enable for Registerfile
    w_e_datamem	: out std_logic := '0';    										-- write enable for Datamemory
    mask_sreg   : out std_logic_vector(7 downto 0) := "00000000"; 				-- SREG bitmask for write_enables
	rel_pc 		: out std_logic_vector(6 downto 0) := "0000000";				-- relative jump (program_counter)
	-- hier kommen noch die ganzen Steuersignale der Multiplexer...
    sel_mux_im   : out std_logic := '0';        								-- Selecteingang für Mux vor RF	    
    sel_mux_ldi  : out std_logic := '0';
    sel_mux_alu	 : out std_logic := '0'
    );
end decoder;

architecture Behavioral of decoder is

begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_regfile, mask_sreg, ...
  dec_mux: process (Instr, state_sreg)
  begin  -- process dec_mux


    -- ACHTUNG!!!
    -- So einfach wie hier unten ist das Ganze nicht! Es soll nur den Anfang erleichtern!
    -- Etwas muss man hier schon nachdenken und sich die Operationen genau ansehen...
    
    -- Vorzuweisung der Signale, um Latches zu verhindern
    --addr_opa <= "00000";
    --addr_opb <= "00000";
    OPCODE <= op_NOP;
    w_e_regfile <= '0';
    w_e_datamem <= '0';
    mask_sreg <= "00000000";
    sel_mux_im <= '0';
    sel_mux_ldi <= '0';
    sel_mux_alu <= '1';
	rel_pc <= "0000000";
	addr_opa <= Instr(8 downto 4);
    addr_opb <= Instr(9) & Instr (3 downto 0);
    data_dcd <= "00000000";
      
	-- SREG: [I][T][H][S][V][N][Z][C]
    case Instr(15 downto 10) is
    
	  
      -- ADD: Adds two registers without the C Flag and places the result in the destination register Rd.
      -- ++
      -- LSL: Shifts all bits in Rd one place to the left. Bit 0 is cleared. Bit 7 is loaded into the C Flag of the SREG. 
      --      This operation effectively multiplies signed and unsigned values by two.
      when "000011" =>        
        OPCODE <= op_add;
        w_e_regfile <= '1';
        mask_sreg <= "00111111";
        
      -- SUB: Subtracts two registers and places the result in the destination register Rd.
      when "000110" =>
        OPCODE <= op_sub;
        w_e_regfile <= '1';
        mask_sreg <= "00111111";
      
      -- CP: This instruction performs a compare between two registers Rd and Rr. None of the registers are changed.
      when "000101" =>
        OPCODE <= op_cp;
        mask_sreg <= "00111111";
      
      -- ROL: Shifts all bits in Rd one place to the left. The C Flag is shifted into bit 0 of Rd. Bit 7 is shifted into the C Flag. 
      -- ++
      -- ADC: Adds two registers and the contents of the C Flag and places the result in the destination register Rd.
      when "000111" =>
        OPCODE <= op_adc;
        w_e_regfile <= '1';
        mask_sreg <= "00111111";
      
      -- AND
	  when "001000" =>
        OPCODE <= op_and;
        w_e_regfile <= '1';
        mask_sreg <= "00011110";
      
      -- EOR 
      when "001001" =>
        OPCODE <= op_eor;
        w_e_regfile <= '1';
        mask_sreg <= "00011110";
        
      -- MOV
	  when "001011" =>
        OPCODE <= op_mov;
        w_e_regfile <= '1';
      

      -- LD
      
      -- INC
      
      when "100100" =>
		-- Load / Store
		case Instr(0) & Instr(3 downto 0) is 
			-- LD
			when "01100" =>
				OPCODE <= op_ld;
				sel_mux_alu <= '0';
			-- ST
			when "11100" =>
				OPCODE <= op_st;
				w_e_datamem <= '1';
			when others => null;
		end case;
		
      --branch commandset A
	  when "111101" =>
		case Instr (2 downto 0) is 
		
			-- brcc ( Branch if Carry Cleared)
			when "000" => 
				if state_sreg(0) = '0' then
					rel_pc <= Instr(9 downto 3);
				end if;
				
			-- brne ( Branch if Not Equal)
			when "001" => 
				if state_sreg(1) = '0' then
					rel_pc <= Instr(9 downto 3);
				end if;
			when others => null;			
		
		end case;

		
      when "100101" =>
		addr_opa <= Instr(8 downto 4);
		w_e_regfile <= '1';
		
		-- 1001 01bx xxxx bbbb
		case Instr(9) & Instr(3 downto 0) is		
			-- COM
			when "00000" =>
			  OPCODE <= op_com;	
			  mask_sreg <= "00011111";
			  
			-- ASR 
			when "00101" =>
			  OPCODE <= op_asr;
			  mask_sreg <= "00011111";
			  
			-- DEC
			when "01010" =>
			  OPCODE <= op_dec;
			  mask_sreg <= "00011110";
			  
			-- INC
			when "00011" =>
			  OPCODE <= op_inc;
			  mask_sreg <= "00011110";
			  
			-- LSR
			when "00110" =>
				OPCODE <= op_lsl;
				mask_sreg <= "00011111";				

			when others => null;
		end case;
		
      -- immediate commands
      when others =>
        sel_mux_im <= '1';
        w_e_regfile <= '1';
        addr_opa <= '1' & Instr(7 downto 4);
        data_dcd <= Instr(11 downto 8) & Instr(3 downto 0);
            
        case Instr(15 downto 12) is          
          -- LDI
          when "1110" =>
            --OPCODE <= op_ldi;
            OPCODE <= op_nop;
            sel_mux_ldi <= '1';
            
            
          -- CPI
          when "0011" =>
            OPCODE <= op_cpi;
          -- SUBI
          when "0101" =>
            OPCODE <= op_subi;
            
          -- ORI
          when "0111" =>
			OPCODE <= op_ori;
          -- ANDI
          when "0110" =>
            OPCODE <= op_andi;
          
          
          -- RJMP
          when "1100" =>  
			rel_pc <= Instr (6 downto 0);
            
          when others => null;
        end case;
    end case;
  end process dec_mux;

  data_dcd <=  Instr(11 downto 8)&Instr(3 downto 0);

end Behavioral;
