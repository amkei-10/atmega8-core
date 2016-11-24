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
    clk   : in STD_LOGIC

    -- ports to "decoder_1"
    --mask_sreg : out std_logic_vector(7 downto 0);

    -- ports to "ALU_1"
    --Status : out STD_LOGIC_VECTOR (7 downto 0)
    );

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  -- outputs of "Program_Counter_1"
  signal addr_pm 			: STD_LOGIC_VECTOR (8 downto 0);

  -- outputs of "prog_mem_1"
  signal Instr 			: STD_LOGIC_VECTOR (15 downto 0);

  -- outputs of "decoder_1"
   signal  	addr_opa    : std_logic_vector(4 downto 0);
   signal  	addr_opb    : std_logic_vector(4 downto 0);
   signal  	data_dcd   	: std_logic_vector(7 downto 0);					-- used for wiring immediate data
   signal  	OPCODE      : std_logic_vector(4 downto 0);
   signal  	mask_sreg   : std_logic_vector(7 downto 0);
   signal 	rel_pc		: std_logic_vector(6 downto 0);
   signal	w_e_datamem	: std_logic;
   signal  	w_e_regfile : std_logic;
   signal 	sel_mux_im 	: std_logic;
   signal 	sel_mux_ldi	: std_logic;
   signal 	sel_mux_alu	: std_logic;

   -- outputs of SREG
   signal state_sreg 	: std_logic_vector(7 downto 0) := "00000000";
   
   -- outputs of Regfile
   signal data_opa 		: std_logic_vector (7 downto 0) := "00000000";
   signal data_opb 		: std_logic_vector (7 downto 0) := "00000000";
   signal addr_r3x 		: std_logic_vector (9 downto 0) := "0000000000";
   
   -- output of multiplexer
   signal data_mux_ldi	: std_logic_vector (7 downto 0) := "00000000";
   signal data_mux_im	: std_logic_vector (7 downto 0) := "00000000";
   signal data_mux_alu	: std_logic_vector (7 downto 0) := "00000000";
  
   -- output of ALU
   signal data_alu 		: std_logic_vector (7 downto 0) := "00000000";
   signal state_alu 		: std_logic_vector(7 downto 0) := "00000000";
  
  -- output of datamemory
  signal data_dm		: std_logic_vector (7 downto 0) := "00000000";
  
  --output of decoder_mem
--  signal w_e_portb 		: STD_LOGIC;
--  signal w_e_portc 		: STD_LOGIC;
--  signal w_e_pinb 		: STD_LOGIC;
--  signal w_e_pinc 		: STD_LOGIC;
--  signal w_e_pind 		: STD_LOGIC;
--  signal w_e_dm			: std_logic;
  signal sel_w_e_dm 	: STD_LOGIC_VECTOR (2 downto 0);
  signal sel_mux_dm 	: STD_LOGIC_VECTOR (2 downto 0);
  
  --port (b,c) and pins(b,c,d)
  signal data_portb		: std_logic_vector (7 downto 0); 
  signal data_portc		: std_logic_vector (7 downto 0);
  signal data_pinb		: std_logic_vector (7 downto 0);
  signal data_pinc		: std_logic_vector (7 downto 0);
  signal data_pind		: std_logic_vector (7 downto 0);
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component Program_Counter
    port (
      reset 		: in  STD_LOGIC;
      clk   		: in  STD_LOGIC;
      addr_pm  		: out STD_LOGIC_VECTOR (8 downto 0);
      rel_pc		: in std_logic_vector(6 downto 0));
  end component;

  component prog_mem
    port (
      addr_pm  		: in  STD_LOGIC_VECTOR (8 downto 0);
      Instr 		: out STD_LOGIC_VECTOR (15 downto 0));
  end component;
   
  component data_mem
    port (
        clk         : in STD_LOGIC;
        data_opa    : in STD_LOGIC_VECTOR (7 downto 0);
        addr_r3x    : in STD_LOGIC_VECTOR (9 downto 0);
--        w_e_portb	: in STD_LOGIC := '0';
--        w_e_portc	: in STD_LOGIC := '0';
--        w_e_pinb 	: in STD_LOGIC := '0';
--        w_e_pinc 	: in STD_LOGIC := '0';
--        w_e_pind 	: in STD_LOGIC := '0';
--        w_e_dm  	: in STD_LOGIC;        
        data_dm     : out STD_LOGIC_VECTOR (7 downto 0);
        sel_w_e_dm 	: in STD_LOGIC_VECTOR (2 downto 0);
        sel_mux_dm : in STD_LOGIC_VECTOR (2 downto 0));
  end component;
   
  component decoder_mem
    port ( 
		addr_r3x 	: in STD_LOGIC_VECTOR (9 downto 0);
--        w_e_portb 	: out STD_LOGIC;
--        w_e_portc 	: out STD_LOGIC;
--        w_e_pinb 	: out STD_LOGIC;
--        w_e_pinc 	: out STD_LOGIC;
--        w_e_pind 	: out STD_LOGIC;
--        w_e_dm 		: out STD_LOGIC;
		w_e_datamem : in STD_LOGIC;
        sel_w_e_dm 	: out STD_LOGIC_VECTOR (2 downto 0);
        sel_mux_dm 	: out STD_LOGIC_VECTOR (2 downto 0));
  end component;
   
  component decoder
    port (
      Instr         : in  std_logic_vector(15 downto 0);
      state_sreg	: in  std_logic_vector(7 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(4 downto 0);
      OPCODE        : out std_logic_vector(4 downto 0);
      w_e_regfile   : out std_logic;
      w_e_datamem 	: out std_logic;
      mask_sreg     : out std_logic_vector(7 downto 0);
      rel_pc		: out std_logic_vector(6 downto 0);
      sel_mux_im 	: out std_logic;
      sel_mux_ldi	: out std_logic;
      sel_mux_alu 	: out std_logic;
      data_dcd		: out std_logic_vector(7 downto 0));
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);
      w_e_regfile   : in  STD_LOGIC;
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_ldi      : in  STD_LOGIC_VECTOR (7 downto 0);
      addr_r3x      : out  STD_LOGIC_VECTOR (9 downto 0));
  end component;

  component ALU
    port (
      OPCODE 		: in  STD_LOGIC_VECTOR (4 downto 0);
      OPA    		: in  STD_LOGIC_VECTOR (7 downto 0);
      OPB    		: in  STD_LOGIC_VECTOR (7 downto 0);
      RES 			: out STD_LOGIC_VECTOR (7 downto 0);
      state_alu	    : out STD_LOGIC_VECTOR (7 downto 0));
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
      addr_pm  => addr_pm,
      rel_pc => rel_pc);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      addr_pm  => addr_pm,
      Instr => Instr);
      
  -- instance "data_mem_1"
  data_mem_1: data_mem
    port map (
	  clk      	=> clk,
      data_opa	=> data_opa,
      addr_r3x  => addr_r3x,
--      w_e_portb => w_e_portb,
--      w_e_portc => w_e_portc,
--      w_e_pinb  => w_e_pinb,
--      w_e_pinc  => w_e_pinc,
--      w_e_pind  => w_e_pind,
--      w_e_dm 	=> w_e_dm,
      sel_w_e_dm => sel_w_e_dm,
      data_dm   => data_dm,
      sel_mux_dm => sel_mux_dm);
  
  decoder_mem_1 : decoder_mem
	port map (
	  addr_r3x		=> addr_r3x,
--	  w_e_portb		=> w_e_portb,
--	  w_e_portc		=> w_e_portc,
--	  w_e_pinb		=> w_e_pinb,
--	  w_e_pinc		=> w_e_pinc,
--	  w_e_pind		=> w_e_pind,
--	  w_e_dm		=> w_e_dm,
	  w_e_datamem	=> w_e_datamem,
      sel_w_e_dm	=> sel_w_e_dm,
	  sel_mux_dm	=> sel_mux_dm);
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      Instr         => Instr,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      OPCODE        => OPCODE,
      w_e_regfile   => w_e_regfile,
      w_e_datamem	=> w_e_datamem,
      mask_sreg      => mask_sreg,
      state_sreg	=> state_sreg,
      rel_pc		=> rel_pc,
	  sel_mux_im 	=> sel_mux_im,
	  sel_mux_ldi	=> sel_mux_ldi,
      sel_mux_alu	=> sel_mux_alu,
      data_dcd		=> data_dcd);

  -- instance "Reg_File_1"

  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      w_e_regfile   => w_e_regfile,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_ldi  	=> data_mux_ldi,
      addr_r3x		=> addr_r3x);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> OPCODE,
      OPA    		=> data_opa,
      OPB    		=> data_mux_im,
      RES 			=> data_alu,
      state_alu		=> state_alu);




      
	data_mux_im  <= data_dcd when (sel_mux_im = '1') else data_opb; 
	data_mux_ldi <= data_dcd when (sel_mux_ldi = '1') else data_mux_alu;			
	data_mux_alu <= data_alu when (sel_mux_alu = '1') else data_dm;

	


	-- purpose: Schreibprozess
	-- type   : sequential
	-- inputs : clk, mask_sreg, Status
	-- outputs: register_speicher
	write_sreg: process (clk)
	begin
	  if clk'event and clk = '1' then  -- rising clock edge
		if reset = '1' then
			state_sreg <= "00000000";
		else
			state_sreg <= (state_alu and mask_sreg) or (state_sreg and not mask_sreg);
		end if;
	  end if;
	end process write_sreg;

	

end Behavioral;
