-------------------------------------------------------------------------------
-- Title      : Instruction Decoder
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : decoder.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
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
    OPCODE      : out std_logic_vector(3 downto 0) 	:= (others => '0'); -- Opcode for ALU
    w_e_rf 		: out std_logic;    									-- write enable for Registerfile
    w_e_dm 		: out std_logic;    									-- write enable for Data/IO-mem
    en_rcall	: out std_logic;    									-- mux-selector (see IE @ toplevel)
    mask_sreg   : out std_logic_vector(1 downto 0) 	:= (others => '0'); -- SREG bitmask
	jmpcode		: out std_logic_vector(1 downto 0) := jmpCode_inc;		
    stack_code	: out std_logic_vector(1 downto 0);						
    en_opB		: out std_logic;
    sel_alu		: out std_logic;
    en_Z		: out std_logic;
    opc_code	: out std_logic_vector(1 downto 0)
    );
end decoder;

architecture Behavioral of decoder is
begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_rf, mask_sreg, ...
  dec_mux: process (Instr)
  begin  -- process dec_mux

    --prevent latches
    OPCODE <= op_nop;
    opc_code <= opcCode_zero;
    mask_sreg <= (others => '0');
    
    -- 11:0 			-> rjmp + rcall
	-- 11:8 & 3:0		-> ldi, cpi, subi, ori, andi
	-- 9:3				-> branch
	data_opim <= Instr(11 downto 8) & Instr(3 downto 0);    
	jmpcode <= jmpCode_inc;
	addr_opa <= Instr(8 downto 4);
    addr_opb <= "0"&Instr(9) & Instr (3 downto 0);
    en_Z <= '0';
    
    --control pins
    en_opB <= '1';
    en_rcall <= '0';
    sel_alu <= '1';
    w_e_rf <= '0';
    w_e_dm <= '0';
    
    stack_code <=  (others => '0');
    
	-- SREG: [I][T][H][S][V][N][Z][C]
    case Instr(15 downto 10) is    
	  
      -- ADD: Adds two registers without the C Flag and places the result in the destination register Rd.
      -- LSL: Shifts all bits in Rd one place to the left. Bit 0 is cleared. Bit 7 is loaded into the C Flag of the SREG.       
      when "000011" =>        
        OPCODE <= op_add;
        w_e_rf <= '1';
        --mask_sreg <= "111";
        mask_sreg <= "11";
        
      -- SUB: Subtracts two registers and places the result in the destination register Rd.
      when "000110" =>
        OPCODE <= op_sub;
        opc_code <= opcCode_one;
        w_e_rf <= '1';
        --mask_sreg <= "111";
        mask_sreg <= "11";
      
      -- CP: This instruction performs a compare between two registers Rd and Rr. None of the registers are changed.
      when "000101" =>
        OPCODE <= op_sub;
        opc_code <= opcCode_one;
        --mask_sreg <= "111";
        mask_sreg <= "11";
      
      -- ROL: Shifts all bits in Rd one place to the left. The C Flag is shifted into bit 0 of Rd. Bit 7 is shifted into the C Flag. 
      -- ADC: Adds two registers and the contents of the C Flag and places the result in the destination register Rd.
      when "000111" =>
        OPCODE <= op_add;
        opc_code <= opcCode_carry;
        w_e_rf <= '1';
        --mask_sreg <= "111";
        mask_sreg <= "11";
      
      -- AND: Performs the logical AND between register Rd and register Rr, and places the result in the destination register Rd.
	  when "001000" =>
        OPCODE <= op_and;
        w_e_rf <= '1';
		--mask_sreg <= "110";
		mask_sreg <= "10";
		
      -- EOR 
      when "001001" =>
        OPCODE <= op_eor;
        w_e_rf <= '1';
        --mask_sreg <= "110";
		mask_sreg <= "10";
      
      -- OR 
      when "001010" =>
        OPCODE <= op_or;
        w_e_rf <= '1';
        --mask_sreg <= "110";
		mask_sreg <= "10";
        
      -- MOV
	  when "001011" =>
        OPCODE <= op_mov;
        w_e_rf <= '1';
 
      
      when "100000" =>
		
		-- Load(LD/LDD) : 	1000 000d dddd 0000 (w_e_rf)
		-- Store(ST/STD) : 	1000 001r rrrr 0000 (w_e_dm)
		if Instr(3 downto 0) = "0000" then
			sel_alu <= '0';
			w_e_rf <= not Instr(9);
			w_e_dm <= Instr(9);
			--en_opB <= '0';
			en_Z <= '1';			
		end if;
		
	  -- branch: 1111 0?ll llll l00?
	  -- lead data over addrA and opim wires
	  when "111101" | "111100" =>
		en_opB <= '0';					--disbale forwarding in IF
		jmpcode <= jmpCode_relBranch;
		OPCODE <= op_nop;
		--rel_pc <= Instr(9)&Instr(9)&Instr(9 downto 3);
		case Instr(10) & Instr(2 downto 0) is
			-- brcc ( Branch if Carry Cleared)
			when "1000" => OPCODE <= op_lsr;	
			-- brne ( Branch if Not Equal)
			when "1001" => OPCODE <= op_and;
			-- brcs ( branch if carry set )
			when "0000" => OPCODE <= op_or;
			-- breq ( Branch if Equal)
			when "0001" => OPCODE <= op_add;
			when others => jmpcode <= jmpCode_inc;
		end case;
		
		
      when "100101" =>
		w_e_rf <= '1';
		addr_opb <= "0"&Instr(8 downto 4);
		
		-- 1001 01bx xxxx bbbb
		case Instr(9) & Instr(8) & Instr(3 downto 0) is		
			-- COM: performs a One???s Complement of register Rd
			when "000000" | "010000" =>
			  OPCODE <= op_com;	
			  opc_code <= opcCode_one;
			  --mask_sreg <= "111";
			  mask_sreg <= "11";
			  
			-- ASR: Arithmetic Shift Right
			when "010101" | "000101" =>
			  OPCODE <= op_asr;
			  --mask_sreg <= "111";
			  mask_sreg <= "11";
			  
			-- DEC (subi with opim=00000001)
			when "011010" | "001010"=>
			  OPCODE <= op_sub;
			  opc_code <= opcCode_one;
			  --mask_sreg <= "110";
			  mask_sreg <= "10";
			  en_opB <= '0';
			  data_opim <= "00000001";
			  
			-- INC (subi with opim=11111111)
			when "010011" | "000011"=>
			  OPCODE <= op_sub;
			  opc_code <= opcCode_one;
			  --mask_sreg <= "110";
			  mask_sreg <= "10";
			  en_opB <= '0';
			  data_opim <= "11111111";
			  
			-- LSR
			when "010110" | "000110" =>
				OPCODE <= op_lsr;
				--mask_sreg <= "111";
				mask_sreg <= "11";
		
			-- RET
			when "011000" =>
				w_e_rf <= '0';
				sel_alu <= '0';
				stack_code <= stackOP_pop;
				jmpcode <= jmpCode_abs;
				OPCODE <= op_mov;

			-- SEC & CLC
			when "001000" => 
				OPCODE <= Instr(7) & not(Instr(7)) & not(Instr(7)) & not(Instr(7));	--@see pkg_processor.vhd
				--mask_sreg <= "001";
				mask_sreg <= "01";
				w_e_rf <= '0';
				
			when others => w_e_rf <= '0';
		end case;
		
	  
	  --PUSH: 1001 001d dddd 1111 	(w_e_dm)
	  --POP	: 1001 000d dddd 1111	(w_e_rf)
	  when "100100" =>		  
		if Instr(3 downto 0) = "1111" then
			--stack_code <= '0' & Instr(9) & not Instr(9);
			stack_code <= Instr(9) & not Instr(9);
			w_e_rf <= not Instr(9);
			w_e_dm <= Instr(9);
			sel_alu <= '0';
			en_opB <= '0';
		end if;
	  	
		
      -- immediate + rel commands + in/out
      when others =>
        addr_opa <= '1' & Instr(7 downto 4);    						-- MSB = offset for im-commands (r16...r31)
        en_opB <= '0';
        w_e_rf <= '1';
         
        case Instr(15 downto 12) is 
		  
		  -- LDI
          when "1110" =>
            OPCODE <= op_mov;                       
            
          -- CPI
          when "0011" =>
            OPCODE <= op_sub;
            opc_code <= opcCode_one;
            --mask_sreg <= "111"; 
            mask_sreg <= "11"; 
            w_e_rf <= '0';
            
          -- SUBI
          when "0101" =>
            OPCODE <= op_sub;
            opc_code <= opcCode_one;
            --mask_sreg <= "111";
            mask_sreg <= "11"; 
                        
          -- ORI
          when "0110" =>
			OPCODE <= op_or;
			--mask_sreg <= "110";
			mask_sreg <= "10";
            			
          -- ANDI
          when "0111" =>
            OPCODE <= op_and;
            --mask_sreg <= "110";
            mask_sreg <= "10";
                      
          -- RJMP
          when "1100" =>  
			OPCODE <= op_mov;
			--rel_pc <= Instr(8 downto 0);
            jmpcode <= jmpCode_relNoCond;
            w_e_rf <= '0';
            
          -- RCALL
          when "1101" =>
			OPCODE <= op_mov;
			--rel_pc <= Instr(8 downto 0);
			stack_code <= stackOP_push;
			jmpcode <= jmpCode_relNoCond;
			w_e_rf <= '0';
			w_e_dm <= '1';
			en_rcall <= '1';
        
		  --OUT:1011 1AAr rrrr AAAA : Stores data from register Rr to I/O Space
		  --IN:	1011 0AAd dddd AAAA : Loads data from the I/O Space into register Rd
          when "1011" => 
		    addr_opa <= Instr(8 downto 4);
		    -- in/out addr-operant    
			addr_opb(5) <= Instr(10);
			--en_Z <= '0';
			sel_alu <= '0';        
			w_e_rf <= not Instr(11);
			w_e_dm <= Instr(11);
			--en_opB <= '1';
		  
		  when others => OPCODE <= op_nop;
		end case;
    end case;
    
  end process dec_mux;  


end Behavioral;
