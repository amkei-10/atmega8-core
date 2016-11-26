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
    Instr       : in  std_logic_vector(15 downto 0);  -- Eingang vom Programmspeicher
    addr_opa    : out std_logic_vector(4 downto 0);   -- Adresse von 1. Operand
    addr_opb    : out std_logic_vector(4 downto 0);   -- Adresse von 2. Operand
    OPCODE      : out std_logic_vector(3 downto 0);   -- Opcode für ALU
    w_e_regfile : out std_logic;         -- write enable for Registerfile
    w_e_SREG    : out std_logic_vector(7 downto 0); -- einzeln Write_enables für SREG - Bits

    -- hier kommen noch die ganzen Steuersignale der Multiplexer...
    sel_immediate: out std_logic        -- Selecteingang für Mux vor RF

    );
end decoder;

architecture Behavioral of decoder is

begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_regfile, w_e_SREG, ...
  dec_mux: process (Instr)
  begin  -- process dec_mux


    -- ACHTUNG!!!
    -- So einfach wie hier unten ist das Ganze nicht! Es soll nur den Anfang erleichtern!
    -- Etwas muss man hier schon nachdenken und sich die Operationen genau ansehen...
    
    -- Vorzuweisung der Signale, um Latches zu verhindern
    addr_opa <= "00000";
    addr_opb <= "00000";
    OPCODE <= op_NOP;
    w_e_regfile <= '0';
    w_e_SREG <= "00000000";
    sel_immediate <= '0';

    case Instr(15 downto 10) is
      -- ADD
      when "000011" =>
        addr_opa <= Instr(8 downto 4);
        addr_opb <= Instr(9) & Instr (3 downto 0);
        OPCODE <= op_add;
        w_e_regfile <= '1';
        w_e_SREG <= "00111111";
      -- SUB
      when "000110" =>
        addr_opa <= Instr(8 downto 4);
        addr_opb <= Instr(9) & Instr (3 downto 0);
        OPCODE <= op_sub;
        w_e_regfile <= '1';
        w_e_SREG <= "00111111";
      when "001010" =>
        addr_opa <= Instr(8 downto 4);
        addr_opb <= Instr(9) & Instr (3 downto 0);
        OPCODE <= op_or;
        w_e_regfile <= '1';
        w_e_SREG <= "00011110";

      when others =>
        case Instr(15 downto 12) is
          when "1110" =>
            addr_opa <= '1' & Instr(7 downto 4);
            addr_opb <= Instr(9) & Instr (3 downto 0);
            OPCODE <= op_add;
            w_e_regfile <= '1';
            w_e_SREG <= "00000000";
            sel_immediate <= '1';
          when others => null;
        end case;
    end case;
  end process dec_mux;

end Behavioral;
