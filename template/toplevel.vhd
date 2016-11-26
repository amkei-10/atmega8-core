----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:45:28 PM
-- Design Name: 
-- Module Name: toplevel - Behavioral
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
use IEEE.numeric_std.all;
use work.pkg_processor.all;
use work.pkg_instrmem.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port (

    -- global ports
    reset : in STD_LOGIC;
    clk   : in STD_LOGIC;

    -- ports to "decoder_1"
    w_e_SREG : out std_logic_vector(7 downto 0);

    -- ports to "ALU_1"
    Status : out STD_LOGIC_VECTOR (7 downto 0));

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  -- outputs of "Program_Counter_1"
  signal Addr : STD_LOGIC_VECTOR (8 downto 0);

  -- outputs of "prog_mem_1"
  signal Instr : STD_LOGIC_VECTOR (15 downto 0);

  -- outputs of "decoder_1"
   signal  addr_opa    : std_logic_vector(4 downto 0);
   signal  addr_opb    : std_logic_vector(4 downto 0);
   signal  OPCODE      : std_logic_vector(3 downto 0);
   signal  w_e_regfile : std_logic;
   signal sel_immediate : std_logic;

  -- outputs of Regfile
  signal data_opa : std_logic_vector (7 downto 0);
  signal data_opb : std_logic_vector (7 downto 0);
  signal data_res : std_logic_vector(7 downto 0);

  -- auxiliary signals
  signal PM_data : std_logic_vector(7 downto 0);  -- used for wiring immediate data
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component Program_Counter
    port (
      reset : in  STD_LOGIC;
      clk   : in  STD_LOGIC;
      Addr  : out STD_LOGIC_VECTOR (8 downto 0));
  end component;

  component prog_mem
    port (
      Addr  : in  STD_LOGIC_VECTOR (8 downto 0);
      Instr : out STD_LOGIC_VECTOR (15 downto 0));
  end component;
  
 
  component decoder
    port (
      Instr         : in  std_logic_vector(15 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(4 downto 0);
      OPCODE        : out std_logic_vector(3 downto 0);
      w_e_regfile   : out std_logic;
      w_e_SREG      : out std_logic_vector(7 downto 0);
      sel_immediate : out std_logic);
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);
      w_e_regfile   : in  STD_LOGIC;
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_res      : in  STD_LOGIC_VECTOR (7 downto 0);
      data_pm       : in  STD_LOGIC_VECTOR (7 downto 0);
      sel_immediate : in  STD_LOGIC);
  end component;

  component ALU
    port (
      OPCODE : in  STD_LOGIC_VECTOR (3 downto 0);
      OPA    : in  STD_LOGIC_VECTOR (7 downto 0);
      OPB    : in  STD_LOGIC_VECTOR (7 downto 0);
      RES    : out STD_LOGIC_VECTOR (7 downto 0);
      Status : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "Program_Counter_1"
  Program_Counter_1: Program_Counter
    port map (
      reset => reset,
      clk   => clk,
      Addr  => Addr);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      Addr  => Addr,
      Instr => Instr);
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      Instr         => Instr,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      OPCODE        => OPCODE,
      w_e_regfile   => w_e_regfile,
      w_e_SREG      => w_e_SREG,
      sel_immediate => sel_immediate);

  -- instance "Reg_File_1"

  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      w_e_regfile   => w_e_regfile,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_res      => data_res,
      data_pm       => PM_Data,
      sel_immediate => sel_immediate);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE => OPCODE,
      OPA    => data_opa,
      OPB    => data_opb,
      RES    => data_res,
      Status => Status);

  PM_Data <=  Instr(11 downto 8)&Instr(3 downto 0);

end Behavioral;
