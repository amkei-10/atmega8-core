----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 09:44:25 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use ieee.numeric_std.all;
library work;
use work.pkg_processor.all;


entity ALU is
    Port ( OPCODE 		: in STD_LOGIC_VECTOR (4 downto 0) 	:= "00000";
           OPA 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= x"00";
           OPB 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= x"00";
           RES 			: out STD_LOGIC_VECTOR (7 downto 0) := x"00";
           state_alu	: out STD_LOGIC_VECTOR (7 downto 0)	:= x"00");
end ALU;

architecture Behavioral of ALU is
  signal z : std_logic := '0';            -- Zero Flag
  signal c : std_logic := '0';            -- Carry Flag
  signal v : std_logic := '0';            -- Overflow Flag
  signal n : std_logic := '0';            -- negative flag
  signal s : std_logic := '0';            -- sign flag
  signal erg : std_logic_vector(7 downto 0);  -- Zwischenergebnis
begin
  -- purpose: Kern-ALU zur Berechnung des Datenausganges
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE
  -- outputs: erg
  -- todo	: optimieren/minimieren (24.11.16) ADD/SUB/INC/DEC/SUBI/CP/CPI
  kern_ALU: process (OPA, OPB, OPCODE)
  begin  -- process kern_ALU
    erg <= "00000000";                  -- verhindert Latches
    
    case OPCODE is

      when op_add | op_sub | op_inc | op_dec | op_adc =>
        erg <= std_logic_vector(unsigned(OPA) + unsigned(OPB));

	  when op_com =>
        erg <= std_logic_vector(x"FF" - unsigned(OPA));
        
      when op_or =>
        erg <= OPA or OPB;
        
      when op_eor =>
        erg <= OPA xor OPB;

	  when op_and =>
        erg <= OPA and OPB;
        
      when op_mov =>
        erg <= OPB;
		
	  when op_lsr => 
		erg <= '0' & OPA(7 downto 1);
        
       when op_asr => 
		erg <= OPA(7) & OPA(7 downto 1);
        
      when others => null;
    end case;
  end process kern_ALU;



  -- purpose: berechnet die stateflagsw_e_sreg
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE, erg
  -- outputs: z, c, v, n
  Berechnung_SREG: process (OPA, OPB, OPCODE, erg, n, c)	
  begin  -- process Berechnung_SREG
    z<=not (erg(7) or erg(6) or erg(5) or erg(4) or erg(3) or erg(2) or erg(1) or erg(0));

	-- Default-Setting for following commands: 
	-- AND, ANDI (...)
    n <= erg(7);
    c <= '0';                           -- um Latches zu verhindern
    v <= '0';
    
    case OPCODE is
      -- ADD or ADC
      when op_add | op_adc =>
		c<=(OPA(7) AND OPB(7)) OR (OPB(7) AND not erg(7)) OR (not erg(7) AND OPA(7));
		v<=(OPA(7) AND OPB(7) AND (not erg(7))) OR ((not OPA(7)) and (not OPB(7)) and  erg(7));
      
      -- INC
	  when op_inc =>
		v<=erg(7) and not(erg(6) or erg(5) or erg(4) or erg(3) or erg(2) or erg(1) or erg(0));        
		  
      -- SUB
      -- SUBI
      -- CP
      -- CPI
      when op_sub =>
		c<=(not OPA(7) and OPB(7)) or (OPB(7) and erg(7)) or (erg(7) and not OPA(7));
		v<=(OPA(7) and not OPB(7) and not erg(7)) or (not OPA(7) and OPB(7) and erg(7));		
	  
	  -- COM
	  when op_com =>
		c<='1';
		v<='0';
	  
	  -- ASR 
	  when op_asr =>
		c<=OPA(0);
		v<=(n xor c);
	  
	  -- DEC 
	  when op_dec =>
		v<=(not erg(7) and erg(6) and erg(5) and erg(4) and erg(3) and erg(2) and erg(1) and erg(0));		
		
	  -- LSL
	  --when op_lsl =>
		--c<=OPA(7);
		--v<=(n xor c);
		
	  -- LSR or EOR
	  when op_lsr | op_eor =>
		c<=OPA(0);
		n<='0';
		v<=(n xor c);

	  -- AND / ANDI
	  when op_and =>
	    v<='0';
	    n<=erg(7);	    

      when others => null;
    end case;
    
  end process Berechnung_SREG;  

  s <= v xor n;
  RES <= erg;
  state_alu <= '0' & '0' & '0' & s & v & n & z & c;
  
end Behavioral;
