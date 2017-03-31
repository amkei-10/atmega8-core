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

	signal reset		: std_logic := '0'; 
	--signal clk		: std_logic := '0'; 
	signal locked		: std_logic := '0'; 

	-- outputs of "prog_cnt_1"
  	signal addr_pm 		: unsigned (PMADDR_WIDTH-1 downto 0);

	-- outputs of "prog_mem_1"
	signal instr 		: STD_LOGIC_VECTOR (15 downto 0);

	-- outputs of instr_fetch
    signal instr_IF		: STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
    signal addr_pm_IF	: STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    signal rel_pc_WB	: std_logic_vector(PMADDR_WIDTH-1 downto 0);
	

	-- outputs of "decoder_1"
 	signal 	addr_opa    : std_logic_vector(4 downto 0) := (others => '0');
 	signal 	addr_opb    : std_logic_vector(5 downto 0) := (others => '0');
 	signal 	data_opim  	: std_logic_vector(7 downto 0) := (others => '0');
 	signal 	opcode      : std_logic_vector(4 downto 0) := (others => '0');
 	signal 	mask_sreg   : std_logic_vector(2 downto 0) := (others => '0');
 	--signal 	rel_pc		: std_logic_vector(PMADDR_WIDTH-1 downto 0);
 	signal	jmpcode		: std_logic_vector(1 downto 0) := (others => '0');
 	signal 	w_e_regf 	: bit;
 	signal 	sel_opb		: bit;
 	signal 	sel_alu		: bit;
    signal 	sel_Zaddr	: bit;
	signal  mdec_op		: std_logic_vector(2 downto 0) := (others => '0');
	
	-- outputs of SREG
 	signal state_sreg 	: std_logic_vector (2 downto 0) := (others => '0');
   
    -- outputs of Regfile
 	signal data_opa 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_opb 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal addr_Z		: std_logic_vector (9 downto 0) := (others => '0');


	--outputs of instr_exec
    signal addr_opa_IE  : std_logic_vector(4 downto 0) := (others => '0');
    signal addr_opb_IE  : std_logic_vector(5 downto 0) := (others => '0');
    signal addr_Z_IE	: std_logic_vector (9 downto 0) := (others => '0');
    signal data_opa_IE	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_opb_IE	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_opim_IE	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_dm_IE	: STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
    signal opcode_IE	: std_logic_vector(4 downto 0) := (others => '0');
    signal jmpcode_IE	: std_logic_vector(1 downto 0) := jmp_code_inc;
	signal mask_sreg_IE	: STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
	signal mdec_op_IE	: std_logic_vector(2 downto 0) := (others => '0');
	signal addr_dm_IE	: std_logic_vector(9 downto 0) := (others => '0');
	signal addr_pm_IE	: std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal sel_alu_IE	: bit := '0';
	signal sel_opb_IE	: bit := '1';
	signal w_e_regf_IE	: bit := '0';
	signal sel_opa_fw	: bit := '0';
    signal sel_opb_fw	: bit := '0';
    signal sel_Zaddr_IE	: bit := '0';
    signal sel_ZH_fw	: bit := '0';
    signal sel_ZL_fw	: bit := '0';
   
	-- output of pipe_WB
	signal data_alu_WB 		: STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
    signal data_dm_WB		: STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    signal state_sreg_WB	: STD_LOGIC_VECTOR (2 downto 0):= (others => '0');
    signal addr_opa_WB		: std_logic_vector (4 downto 0);
    signal w_e_regf_WB		: bit := '0';
    signal sel_alu_WB		: bit := '0';
    signal sel_opa_fw_IE	: bit := '0';
    signal sel_opb_fw_IE	: bit := '0';
    signal sel_ZH_fw_IE		: bit := '0';
    signal sel_ZL_fw_IE		: bit := '0';
    signal jmpcode_WB		: std_logic_vector(1 downto 0) := jmp_code_inc;
    signal addr_dm_WB		: STD_LOGIC_VECTOR (9 downto 0):= (others => '0');
    signal w_e_dm_WB		: std_logic := '0';
    
	-- output of multiplexer
 	signal mux_pc		: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');

 	
 	signal mux_alu_dm	: std_logic_vector (7 downto 0) := (others => '0');
 	signal mux_data_dm	: std_logic_vector (PMADDR_WIDTH-1 downto 0);
	signal mux_opb_opim	: std_logic_vector (7 downto 0) := (others => '0');
	signal mux_bconst	: std_logic_vector (7 downto 0) := (others => '0');
	signal mux_addr_dm  : std_logic_vector (9 downto 0) := (others => '0');	
	--signal mux_w_e_regf  : bit;
	signal mux_opa_fw_WB: std_logic_vector(7 downto 0) := (others => '0');
	signal mux_opb_fw_WB: std_logic_vector(7 downto 0) := (others => '0');	
	signal mux_opa_fw: std_logic_vector(7 downto 0) := (others => '0');
	signal mux_opb_fw: std_logic_vector(7 downto 0) := (others => '0');
	signal mux_if_nop 	: STD_LOGIC_VECTOR (15 downto 0):= (others => '0');

	signal mux_we_rf	: bit := '1';
	signal mux_w_e_regf_IE: bit := '1';
	signal mux_mdec_op	: std_logic_vector(2 downto 0) := (others => '0');

	signal mux_ZH_fw	: std_logic_vector(1 downto 0) := (others => '0');
	signal mux_ZL_fw	: std_logic_vector(7 downto 0) := (others => '0');	
	signal mux_Z_fw_merged	: std_logic_vector(9 downto 0) := (others => '0');
	
	signal mux_ZH_fw_IE	: std_logic_vector(1 downto 0) := (others => '0');
	signal mux_ZL_fw_IE	: std_logic_vector(7 downto 0) := (others => '0');
	
	signal mux_jmpcode	: std_logic_vector(1 downto 0) := (others => '0');
	
	signal mux_pc_op	: unsigned (PMADDR_WIDTH-1 downto 0) := "000000001";
	
	-- output of ALU
	signal data_alu 	: std_logic_vector (7 downto 0) := (others => '0');
	signal state_alu 	: std_logic_vector (2 downto 0) := (others => '0');
  
	-- output of datamemory
	signal data_dm_out	: std_logic_vector (PMADDR_WIDTH-1 downto 0);
  
	-- output of prog_jmp
	--signal 	rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0);
	signal 	flush_IE		: std_logic := '0';							
	signal 	flush_WB		: std_logic := '0';							
	signal	jmpcode_PJ		: std_logic_vector(1 downto 0) := jmp_code_inc;
  
	-- flipflops
	--signal rel_pc			: std_logic_vector(PMADDR_WIDTH-1 downto 0) := "000000001";

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component prog_cnt
    port (
      clk   		: in  STD_LOGIC;
      reset 		: in  STD_LOGIC;
      jmpcode		: in  std_logic_vector(1 downto 0):= (others => '0');
      addr_op		: in unsigned(PMADDR_WIDTH-1 downto 0);      
      addr_out 		: out unsigned (PMADDR_WIDTH-1 downto 0));
  end component;

  component prog_mem
    port (
      addr  		: in  unsigned (PMADDR_WIDTH-1 downto 0);
      instr 		: out STD_LOGIC_VECTOR (15 downto 0));
  end component;   
   
  component instr_fetch
    port (
		clk   		: in  std_logic := '0';
		instr_in 	: in  STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
		instr_out	: out STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
		addr_in		: in unsigned (PMADDR_WIDTH-1 downto 0);
		addr_out	: out std_logic_vector (PMADDR_WIDTH-1 downto 0);
		rel_pc_out	: out std_logic_vector(PMADDR_WIDTH-1 downto 0));
  end component;    
   
  component instr_exec
    port (
		clk   			: in std_logic := '0';    

		addr_opa_in		: in STD_LOGIC_VECTOR (4 downto 0);
		addr_opa_out	: out STD_LOGIC_VECTOR (4 downto 0);
		--addr_opa_out2	: out std_logic_vector (4 downto 0);
		addr_opb_in		: in STD_LOGIC_VECTOR (5 downto 0);    
		addr_opb_out	: out STD_LOGIC_VECTOR (5 downto 0);
		addr_Z_in		: in std_logic_vector (9 downto 0);
		addr_Z_out		: out std_logic_vector (9 downto 0);
		
		opcode_in		: in std_logic_vector(4 downto 0);
		opcode_out		: out std_logic_vector(4 downto 0);
		jmpcode_in		: in std_logic_vector(1 downto 0);
		jmpcode_out		: out std_logic_vector(1 downto 0);
		mask_sreg_in	: in STD_LOGIC_VECTOR (2 downto 0);
		mask_sreg_out	: out STD_LOGIC_VECTOR (2 downto 0);
		mdec_op_in		: in std_logic_vector(2 downto 0);
		mdec_op_out		: out std_logic_vector(2 downto 0);
		
		data_opa_in		: in STD_LOGIC_VECTOR (7 downto 0);
		data_opa_out	: out STD_LOGIC_VECTOR (7 downto 0);
		data_opb_in		: in STD_LOGIC_VECTOR (7 downto 0);
		data_opb_out	: out STD_LOGIC_VECTOR (7 downto 0);
		addr_pm_in		: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);-- used as data (store)
		addr_pm_out		: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
					
		w_e_in			: bit;
		w_e_out			: out bit;
		
		sel_alu_in		: in bit;
		sel_alu_out		: out bit;
		sel_opb_in		: in bit;
		sel_opb_out		: out bit;
		sel_Zaddr_in	: in bit;
		sel_Zaddr_out	: out bit;
		
		sel_opa_fw		: out bit;
		sel_opb_fw		: out bit;
		sel_ZH_fw		: out bit;
		sel_ZL_fw		: out bit		
    );
  end component; 
   
  component pipe_WB
  port (
    clk   			: in std_logic := '0';
    
    addr_opa_in		: in std_logic_vector (4 downto 0);
    --addr_opa_out	: out std_logic_vector (4 downto 0);
    addr_opb_in		: in std_logic_vector (4 downto 0);
    
    jmpcode_in		: in std_logic_vector(1 downto 0) := jmp_code_inc;
    jmpcode_out		: out std_logic_vector(1 downto 0) := jmp_code_inc;
    
    mask_sreg_in	: in std_logic_vector(2 downto 0) := (others => '0');
    state_alu_in	: in std_logic_vector(2 downto 0) := (others => '0');
    state_sreg_out	: out std_logic_vector(2 downto 0) := (others => '0');
    alu_in			: in STD_LOGIC_VECTOR (7 downto 0):= (others => '0');    
    alu_out 		: out STD_LOGIC_VECTOR (7 downto 0):= (others => '0');    
    dm_in			: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    dm_out			: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    
    w_e_in			: in bit;
    w_e_out			: out bit;        

    sel_opb_in		: in bit;
    sel_alu_in		: in bit;
    sel_alu_out		: out bit;
    flush_in		: in std_logic;
    flush_out		: out std_logic;
    
    sel_opa_fw		: out bit;
    sel_opb_fw		: out bit;
    sel_ZH_fw		: out bit;
    sel_ZL_fw		: out bit
  );
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
      instr         : in  std_logic_vector(15 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(5 downto 0);
      opcode        : out std_logic_vector(4 downto 0);
      w_e_regf   	: out bit;
      mask_sreg     : out std_logic_vector(2 downto 0);
      --rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0);
      jmpcode		: out std_logic_vector(1 downto 0);
      sel_opb 		: out bit;
      sel_alu 		: out bit;
      data_opim		: out std_logic_vector(7 downto 0);
	  sel_Zaddr		: out bit;
	  mdec_op		: out std_logic_vector(2 downto 0));
  end component;
  
  component prog_jmp
	port(
		opcode 		: in std_logic_vector(2 downto 0);
		state_sreg	: in std_logic_vector(2 downto 0);
		jmpcode_in	: in std_logic_vector(1 downto 0);
		jmpcode_out	: out std_logic_vector(1 downto 0);
		flush_instr		: out std_logic);
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      w_e   		: in  bit;
      --addr_opa_w    : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);      
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opim     : in  STD_LOGIC_VECTOR (7 downto 0);
      addr_Z      	: out  STD_LOGIC_VECTOR (9 downto 0));
  end component;

  component ALU
    port (
      opcode 		: in STD_LOGIC_VECTOR (4 downto 0) 	:= (others => '0');
      OPA 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      OPB 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      --OPIM			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      CARRY			: in STD_LOGIC := '0';
      RES 			: out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
      state_alu		: out STD_LOGIC_VECTOR (2 downto 0)	:= (others => '0'));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  --clk_wiz_0_1 : clk_wiz
    --port map (
		--clk_in1		=> clk,
		--clk_out1	=> clk,
		--reset		=> reset,
		--locked		=> locked
    --);

  -- instance "prog_cnt_1"
  prog_cnt_1: prog_cnt
    port map (
      clk   		=> clk,
      reset 		=> reset,
      jmpcode		=> jmpcode_WB,
      addr_op  		=> mux_pc,
      addr_out 		=> addr_pm);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      addr  	=> addr_pm,      
      instr 	=> instr);
      
  instr_fetch_1 : instr_fetch
	port map (
	  clk		=> clk,
	  addr_in	=> addr_pm,
	  addr_out	=> addr_pm_IF,
	  instr_in	=> mux_if_nop,
	  rel_pc_out=> rel_pc_WB,
	  instr_out	=> instr_IF);
      
  intr_exec_1 : instr_exec
	port map(
		clk				=> clk,    

		addr_opa_in		=> addr_opa,		
		addr_opa_out	=> addr_opa_IE,			
		--addr_opa_out2	=> addr_opa_WB,
		addr_opb_in		=> addr_opb,
		addr_opb_out	=> addr_opb_IE,
		addr_Z_in		=> mux_Z_fw_merged,
		addr_Z_out		=> addr_Z_IE,		
				
		data_opa_in		=> mux_opa_fw,			
		data_opa_out	=> data_opa_IE,
		data_opb_in		=> mux_opb_fw,      
		data_opb_out	=> data_opb_IE,			
		addr_pm_in		=> addr_pm_IF,			--used as data
		addr_pm_out		=> addr_pm_IE,
		
		w_e_in			=> mux_we_rf,
		w_e_out			=> w_e_regf_IE,

		mdec_op_in		=> mux_mdec_op,
		mdec_op_out		=> mdec_op_IE,
		opcode_in		=> opcode,
		opcode_out		=> opcode_IE,
		jmpcode_in		=> mux_jmpcode,
		jmpcode_out		=> jmpcode_IE,
		mask_sreg_in	=> mask_sreg,
		mask_sreg_out	=> mask_sreg_IE,
		
		sel_alu_in		=> sel_alu,
		sel_alu_out		=> sel_alu_IE,
		sel_opb_in 		=> sel_opb,
		sel_opb_out 	=> sel_opb_IE,
		sel_Zaddr_in	=> sel_Zaddr,
		sel_Zaddr_out	=> sel_Zaddr_IE,
		
		sel_opb_fw		=> sel_opb_fw,
		sel_opa_fw		=> sel_opa_fw,
		sel_ZH_fw		=> sel_ZH_fw,
		sel_ZL_fw		=> sel_ZL_fw
	  );
      
  -- instance "pipe_WB_1"
  pipe_WB_1 : pipe_WB
  port map (
	clk   		=> clk,
	
	addr_opa_in => addr_opa_IE,
    --addr_opa_out => addr_opa_WB,
    addr_opb_in => addr_opb_IE(4 downto 0),
    
    jmpcode_in	=> jmpcode_PJ,
    jmpcode_out	=> jmpcode_WB,
    
	alu_in		=> data_alu,
    alu_out 	=> data_alu_WB,
    dm_in		=> data_dm_out,
    dm_out		=> data_dm_WB,    
    
    mask_sreg_in	=> mask_sreg_IE,
    state_alu_in	=> state_alu,
    state_sreg_out	=> state_sreg_WB,
    
    w_e_in		=> mux_w_e_regf_IE,
    w_e_out		=> w_e_regf_WB,
    
    flush_in	=> flush_IE,
    flush_out	=> flush_WB,
    
    sel_opb_in	=> sel_opb_IE,
    sel_alu_in	=> sel_alu_IE,
    sel_alu_out	=> sel_alu_WB,    
    
    sel_opa_fw	=> sel_opa_fw_IE,
    sel_opb_fw	=> sel_opb_fw_IE,
    sel_ZH_fw	=> sel_ZH_fw_IE,
	sel_ZL_fw	=> sel_ZL_fw_IE
  );

      
  -- instance "datamem_1"
  data_mem_1: data_mem
    port map (
	  clk      	=> 	clk,
      addr_in  	=> 	mux_addr_dm,
      data_in	=> 	mux_data_dm,
      data_out  => 	data_dm_out,
      mdec_op	=> 	mdec_op_IE,
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
      instr         => instr_IF,
      mdec_op		=> mdec_op,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      opcode        => opcode,
      w_e_regf   	=> w_e_regf,
      mask_sreg     => mask_sreg,
      --rel_pc		=> rel_pc,
      jmpcode		=> jmpcode,
	  sel_opb		=> sel_opb,
      sel_alu		=> sel_alu,
      data_opim		=> data_opim,
      sel_Zaddr		=> sel_Zaddr);

  prog_jmp_1: prog_jmp
	port map(
	  opcode		=> opcode_IE(2 downto 0),
	  state_sreg	=> state_sreg_WB,
	  jmpcode_in	=> jmpcode_IE,
	  jmpcode_out	=> jmpcode_PJ,
	  flush_instr	=> flush_IE
	);

  -- instance "Reg_File_1"
  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      --addr_opa_w	=> addr_opa_WB,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb(4 downto 0),
      w_e			=> w_e_regf_WB,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_opim  	=> mux_alu_dm,
      addr_Z		=> addr_Z);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> opcode_IE,
      OPA    		=> mux_opa_fw_WB,
      OPB    		=> mux_opb_fw_WB,
      CARRY			=> state_sreg_WB(0),
      RES 			=> data_alu,
      state_alu		=> state_alu);

	-- ++++++++ --
	-- toplevel --
	-- ++++++++ --
    
    
    -- push & pop == 1 means rcall
    -- data input for DM (data:opa or addr:prog_mem)
	
	-- fw:data_alu_dm
	mux_opa_fw <= mux_alu_dm 	when (sel_opa_fw = '1') 			else data_opa;
	mux_opb_fw <= mux_alu_dm 	when (sel_opb_fw = '1') 			else mux_opb_opim;
	mux_opa_fw_WB <= mux_alu_dm when (sel_opa_fw_IE = '1')			else data_opa_IE;
	mux_opb_fw_WB <= mux_alu_dm when (sel_opb_fw_IE = '1') 			else data_opb_IE;
	mux_opb_opim <= data_opim 	when (sel_opb = '0') 				else data_opb;
	mux_data_dm <= addr_pm_IE 	when (mdec_op_IE = mdec_op_rcall) 	else "0"&mux_opa_fw_WB;
	
	-- fw:addr_dm
	mux_ZH_fw 		<= mux_alu_dm(1 downto 0) 		when (sel_ZH_fw = '1') 		else addr_Z(9 downto 8);
	mux_ZL_fw 		<= mux_alu_dm 					when (sel_ZL_fw = '1') 		else addr_Z(7 downto 0);
	mux_Z_fw_merged <= mux_ZH_fw & mux_ZL_fw;
	mux_ZH_fw_IE 	<= mux_alu_dm(1 downto 0) 		when (sel_ZH_fw_IE = '1') 	else addr_Z_IE(9 downto 8);
	mux_ZL_fw_IE 	<= mux_alu_dm 					when (sel_ZL_fw_IE = '1') 	else addr_Z_IE(7 downto 0);	
	mux_addr_dm 	<= mux_ZH_fw_IE & mux_ZL_fw_IE 	when (sel_Zaddr_IE = '1') 	else "0000"&addr_opb_IE;
	
	-- output of wb_pipeline
	mux_alu_dm <= data_alu_WB when (sel_alu_WB = '1') else data_dm_WB(7 downto 0);  
	

	
		
	-- flush pipeline if jump (branch, ret, rcall, rjump)
	mux_jmpcode 	<= jmpcode 		when (flush_IE = '0') 				else (others => '0');
	mux_we_rf 		<= w_e_regf 	when ((flush_IE) = '0') 			else '0';
	mux_w_e_regf_IE <= w_e_regf_IE;-- 	when ((flush_WB) = '0') 			else '0';
	mux_mdec_op 	<= mdec_op 		when (flush_IE = '0') 				else (others => '0');
	mux_if_nop 		<= instr 		when ((flush_WB OR flush_IE) = '0') else (others => '0');
	mux_pc_op 		<= "000000001" 	when (flush_IE = '0') 				else "111111111";
	
	--set operant for prog_count
	set_pc_offset:process(jmpcode_WB, rel_pc_WB, mux_pc_op, data_dm_WB)
	begin
		case jmpcode_WB is
			--when jmp_code_inc => mux_pc <= "00000000"&not(flush_instr);
			when jmp_code_rel => mux_pc <= unsigned(rel_pc_WB(PMADDR_WIDTH-2) & rel_pc_WB(PMADDR_WIDTH-2 downto 0));
			when jmp_code_abs => mux_pc <= unsigned(data_dm_WB);
			when others => mux_pc <= mux_pc_op;			
		end case;
	end process;	
	
	reset <= ((hw_pind(0) AND hw_pind(1)) AND hw_pind(2) AND (hw_pind(3) AND hw_pind(4)));

end Behavioral;
