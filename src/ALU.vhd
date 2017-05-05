-------------------------------------------------------------------------------
-- Title      : ALU
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : ALU.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.pkg_processor.all;


entity ALU is
    Port ( OPCODE 		: in STD_LOGIC_VECTOR (3 downto 0) 	:= (others => '0');
           OPA 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
           OPB 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
           OPCONST		: in STD_LOGIC 						:= '0';
           RES 			: out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           state_alu	: out STD_LOGIC_VECTOR (1 downto 0)	:= (others => '0'));
end ALU;

architecture Behavioral of ALU is
  signal z : std_logic := '0';            	-- Zero Flag
  signal c : std_logic := '0';            	-- Carry Flag
  --signal v : std_logic := '0';          	-- Overflow Flag
  --signal n : std_logic := '0';            -- negative flag
  --signal s : std_logic := '0';          	-- sign flag
  signal erg : std_logic_vector(7 downto 0);-- Zwischenergebnis
  
  signal OPA_REG : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  signal OPB_REG : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  
begin

	-- purpose: prepairs operants depending by the operation
	-- type   : combinational
	-- inputs : OPA, OPB, OPCODE(3 downto 2)
	-- outputs: OPA_REG, OPB_REG
	setup_operants:process(OPCODE(3 downto 2), OPA, OPB)
	begin
	
		OPA_REG <= OPA;
		OPB_REG <= OPB;
		
		case OPCODE(3 downto 2) is
			when op_sub(3 downto 2)	=> 	OPB_REG <= not OPB;				-- overlap op_lsr
			when op_com(3 downto 2)	=> 	OPB_REG <= not(OPA);			
										OPA_REG <= x"FF";
			when others 			=>	null;				
		end case;
	end process;


  -- purpose: Kern-ALU zur Berechnung des Datenausganges
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE
  -- outputs: erg  
  kern_ALU: process (OPA_REG, OPB_REG, OPCONST, OPCODE(2 downto 0))
	variable opconst_vector : std_logic_vector(7 downto 0);
  begin  -- process kern_ALU
    erg <= "00000000";
    
    opconst_vector := "0000000" & OPCONST;
    
    case OPCODE(2 downto 0) is

      when op_add(2 downto 0) | op_sub(2 downto 0) =>
        erg <= std_logic_vector(unsigned(OPA_REG) + unsigned(OPB_REG) + unsigned(opconst_vector));
        
      when op_or(2 downto 0) =>
        erg <= OPA_REG or OPB_REG;
        
      when op_eor(2 downto 0) =>
        erg <= OPA_REG xor OPB_REG;

	  when op_and(2 downto 0) =>
        erg <= OPA_REG and OPB_REG;
        
      when op_mov(2 downto 0) =>
        erg <= OPB_REG;
		
	  when op_lsr(2 downto 0) => 
		erg <= '0' & OPA_REG(7 downto 1);
        
      when op_asr(2 downto 0) => 
		erg <= OPA_REG(7) & OPA_REG(7 downto 1);
		
      when others => null;
    end case;
  end process kern_ALU;


  -- purpose: berechnet die stateflags
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE(3 downto 2), erg
  -- outputs: z, c
  Berechnung_SREG: process (OPA, OPB, OPCODE(3 downto 2), erg)
	variable MSB : std_logic_vector ( 2 downto 0);
  begin  -- process Berechnung_SREG
    
    z <= '0'; 
    --z<=not (((erg(7) or erg(6)) or (erg(5) or erg(4))) or ((erg(3) or erg(2)) or (erg(1) or erg(0))));   
	
	case erg is
		when "00000000" => z <= '1';
		when others		=> z <= '0';
	end case;
	
	-- Default-Setting for
    c <= '0';
    
    MSB := OPA(7) & OPB(7) & erg(7);
    
    case OPCODE(3 downto 2) is
      -- ADD, ADC
      when op_add(3 downto 2) =>
		--c<=(OPA(7) and OPB(7)) or (OPB(7) and not erg(7)) or (not erg(7) and OPA(7));
		case MSB is
			when "010" | "100" | "110" | "111" => c <= '1';
			when others => null;
		end case;
		  
      -- SUB, SUBI, CP, CPI
      when op_sub(3 downto 2) =>
		--c<=(not OPA(7) and OPB(7)) or (OPB(7) and erg(7)) or (erg(7) and not OPA(7));
		case MSB is
			when "001" | "010" | "011" | "111"	=> c <= '1';
			when others => null;
		end case;	  
	  
	  -- COM, SEC
	  when op_com(3 downto 2) =>
		c<='1';
	  
	  -- ASR, LSR, CLC
	  when op_asr(3 downto 2) =>
		c<=OPA(0);		
	  
      when others => null;
    end case;
    
  end process Berechnung_SREG;  

  --s <= v xor n;
  RES <= erg;
  --state_alu <= '0' & '0' & '0' & s & v & n & z & c;
  state_alu <= z & c;
  
end Behavioral;
