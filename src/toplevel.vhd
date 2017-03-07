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
		--reset  		: in STD_LOGIC;
		clk   		: in STD_LOGIC;
		
		hw_seg_enbl	: out std_logic_vector (3 downto 0) := (others => '0');
		hw_seg_cont	: out std_logic_vector (7 downto 0) := (others => '0');
		
		hw_portb	: out std_logic_vector (7 downto 0) := (others => '0');
		hw_portc	: out std_logic_vector (7 downto 0) := (others => '0');
		
		hw_pinb		: in std_logic_vector (7 downto 0) := (others => '0');
		hw_pinc		: in std_logic_vector (7 downto 0) := (others => '0');
		hw_pind		: in std_logic_vector (4 downto 0) := (others => '0'));		

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

	signal reset		: std_logic; 

	-- outputs of "prog_cnt_1"
  	signal addr_pm 		: unsigned (PMADDR_WIDTH-1 downto 0);

	-- outputs of "prog_mem_1"
	signal Instr 		: STD_LOGIC_VECTOR (15 downto 0);

	-- outputs of instr_fetch
    signal Instr_if_out	: STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
    signal addr_if_out	: unsigned (PMADDR_WIDTH-1 downto 0);

	signal Instr_mux_if : STD_LOGIC_VECTOR (15 downto 0):= (others => '0');

	-- outputs of "decoder_1"
 	signal 	addr_opa    : std_logic_vector(4 downto 0);
 	signal 	addr_opb    : std_logic_vector(5 downto 0);
 	signal 	data_dcd   	: std_logic_vector(7 downto 0);					-- used for wiring immediate data
 	signal 	OPCODE      : std_logic_vector(4 downto 0);
 	signal 	mask_sreg   : std_logic_vector(7 downto 0);
 	signal 	rel_pc		: std_logic_vector(PMADDR_WIDTH-1 downto 0);
 	signal	jmp_code	: std_logic_vector(1 downto 0);
 	signal 	w_e_regf 	: bit;
 	signal 	sel_ldi		: bit;
 	signal 	sel_alu		: bit;
    signal 	sel_maddr	: bit;
	signal  mdec_op		: std_logic_vector(2 downto 0);
	
	-- outputs of SREG
 	signal state_sreg 	: std_logic_vector (7 downto 0) := (others => '0');
   
    -- outputs of Regfile
 	signal data_opa 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_opb 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal addr_r3x_regf: std_logic_vector (9 downto 0) := (others => '0');
   
	-- output of multiplexer
 	signal data_mux_ldi	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_im	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_alu	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_pc	: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
 	signal data_mux_dmin: std_logic_vector (PMADDR_WIDTH-1 downto 0);
	signal data_mux_opb	: std_logic_vector (7 downto 0) := (others => '0');
	signal data_mux_bconst	: std_logic_vector (7 downto 0) := (others => '0');
	signal addr_mux_dm  : std_logic_vector (9 downto 0) := (others => '0');
	
	-- output of ALU
	signal data_alu 	: std_logic_vector (7 downto 0) := (others => '0');
	signal state_alu 	: std_logic_vector (7 downto 0) := (others => '0');
  
	-- output of datamemory
	signal data_dmout		: std_logic_vector (PMADDR_WIDTH-1 downto 0);
  
	signal data_opb_alu	: std_logic_vector (7 downto 0);
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component prog_cnt
    port (
      clk   		: in  STD_LOGIC;
      reset 		: in  STD_LOGIC;
      jmp_code		: in  std_logic_vector(1 downto 0):= (others => '0');
      addr_op		: in unsigned(PMADDR_WIDTH-1 downto 0);      
      addr_out 		: out unsigned (PMADDR_WIDTH-1 downto 0));
  end component;

  component prog_mem
    port (
      addr  		: in  unsigned (PMADDR_WIDTH-1 downto 0);
      Instr 		: out STD_LOGIC_VECTOR (15 downto 0));
  end component;   
   
  component instr_fetch
    port (
		clk   		: in  std_logic := '0';
		instr_in 	: in  STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
		instr_out	: out STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
		addr_in		: in unsigned (PMADDR_WIDTH-1 downto 0);
		addr_out	: out unsigned (PMADDR_WIDTH-1 downto 0));
  end component;    
   
  component data_mem
    port (
			clk 	: in STD_LOGIC;
			mdec_op	: in std_logic_vector(2 downto 0);
			addr_in : in STD_LOGIC_VECTOR (9 downto 0);
			data_in	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
			data_out : out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
			pinb : in STD_LOGIC_VECTOR (7 downto 0);
			pinc : in STD_LOGIC_VECTOR (7 downto 0);
			pind : in STD_LOGIC_VECTOR (4 downto 0);           
			portb : out STD_LOGIC_VECTOR (7 downto 0);
			portc : out STD_LOGIC_VECTOR (7 downto 0);         
			segen : out STD_LOGIC_VECTOR (3 downto 0);
			segcont : out STD_LOGIC_VECTOR (7 downto 0));
  end component;  
   
  component decoder
    port (
      Instr         : in  std_logic_vector(15 downto 0);
      state_sreg	: in  std_logic_vector(7 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(5 downto 0);
      OPCODE        : out std_logic_vector(4 downto 0);
      w_e_regf   	: out bit;
      mask_sreg     : out std_logic_vector(7 downto 0);
      rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0);
      jmp_code		: out std_logic_vector(1 downto 0);
      sel_ldi		: out bit;
      sel_alu 		: out bit;
      data_dcd		: out std_logic_vector(7 downto 0);
	  sel_maddr		: out bit;
	  mdec_op		: out std_logic_vector(2 downto 0));
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      w_e   		: in  bit;
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);      
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_ldi      : in  STD_LOGIC_VECTOR (7 downto 0);
      addr_r3x      : out  STD_LOGIC_VECTOR (9 downto 0));
  end component;

  component ALU
    port (
      OPCODE 		: in STD_LOGIC_VECTOR (4 downto 0) 	:= (others => '0');
      OPA 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      OPB 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      OPIM			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      CARRY			: in STD_LOGIC := '0';
      RES 			: out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
      state_alu		: out STD_LOGIC_VECTOR (7 downto 0)	:= (others => '0'));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "prog_cnt_1"
  prog_cnt_1: prog_cnt
    port map (
      clk   		=> clk,
      reset 		=> reset,
      jmp_code		=> jmp_code,
      addr_op  		=> data_mux_pc,
      addr_out 		=> addr_pm);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      addr  	=> addr_pm,      
      Instr 	=> Instr);
      
  instr_fetch_1 : instr_fetch
	port map (
	  clk		=> clk,
	  addr_in	=> addr_pm,
	  addr_out	=> addr_if_out,
	  instr_in	=> Instr_mux_if,
	  instr_out	=> Instr_if_out);
      
  -- instance "datamem_1"
  data_mem_1: data_mem
    port map (
	  clk      	=> 	clk,
      addr_in  	=> 	addr_mux_dm,
      data_in	=> 	data_mux_dmin,
      data_out  => 	data_dmout,
      mdec_op	=> 	mdec_op,
      pinb		=>  hw_pinb,
      pinc		=>  hw_pinc,
      pind 		=>  hw_pind,
      portb 	=>  hw_portb,
      portc 	=>  hw_portc,           
      segen 	=>  hw_seg_enbl,
      segcont	=>  hw_seg_cont);
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      Instr         => Instr_if_out,
      mdec_op		=> mdec_op,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      OPCODE        => OPCODE,
      w_e_regf   	=> w_e_regf,
      mask_sreg     => mask_sreg,
      state_sreg	=> state_sreg,
      rel_pc		=> rel_pc,
      jmp_code		=> jmp_code,
	  sel_ldi		=> sel_ldi,
      sel_alu		=> sel_alu,
      data_dcd		=> data_dcd,
      sel_maddr		=> sel_maddr);

  -- instance "Reg_File_1"
  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb(4 downto 0),
      w_e   		=> w_e_regf,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_ldi  	=> data_mux_ldi,
      addr_r3x		=> addr_r3x_regf);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> OPCODE,
      OPA    		=> data_opa,
      OPB    		=> data_opb,
      OPIM			=> data_dcd,
      CARRY			=> state_sreg(0),
      RES 			=> data_alu,
      state_alu		=> state_alu);

	-- toplevel logic
    
    -- push & pop == 1 means rcall
	data_mux_dmin <= std_logic_vector(addr_if_out) when (mdec_op(1 downto 0)  = "11") else "0"&data_opa;  
	addr_mux_dm <= addr_r3x_regf when (sel_maddr = '0') else "0000"&addr_opb;	
	
	data_mux_ldi <= data_dcd when (sel_ldi = '1') else data_mux_alu;  
	data_mux_alu <= data_alu when (sel_alu = '1') else data_dmout(7 downto 0);  
	
	set_pc_offset:process(jmp_code, rel_pc, data_dmout)
	begin
		case jmp_code is 
			when jmp_code_inc => data_mux_pc <= "000000001";
			when jmp_code_rel => data_mux_pc <= unsigned(rel_pc(PMADDR_WIDTH-2) & rel_pc(PMADDR_WIDTH-2 downto 0));
			when jmp_code_abs => data_mux_pc <= unsigned(data_dmout);
			when others => data_mux_pc <= (others => '0');
		end case;
	end process;
	
	
	
	--bypass_instrcode:process(jmp_code, Instr, Instr_if_out)
	Instr_mux_if <= Instr when (jmp_code = jmp_code_inc) else (others => '0');
	
	
	
	reset <= hw_pind(0) and hw_pind(1) and hw_pind(2) and hw_pind(3) and hw_pind(4);	
	
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
