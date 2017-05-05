-------------------------------------------------------------------------------
-- Title      : Toplevel
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
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
		clk_in 		: in STD_LOGIC;
		
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
	signal clk			: std_logic := '0'; 
	signal locked		: std_logic := '0'; 

	-- outputs of "prog_cnt_1"
  	signal addr_pm 		: unsigned (PMADDR_WIDTH-1 downto 0);
	signal addr_rel_IF	: std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal instr 		: STD_LOGIC_VECTOR (15 downto 0);

	-- outputs of "decoder_1"
 	signal addr_opa    	: std_logic_vector(4 downto 0) := (others => '0');
 	signal addr_opb    	: std_logic_vector(5 downto 0) := (others => '0');
 	signal data_opim  	: std_logic_vector(7 downto 0) := (others => '0');
 	signal opcode      	: std_logic_vector(3 downto 0) := (others => '0');
 	signal mask_sreg   	: std_logic_vector(1 downto 0) := (others => '0');
 	signal jmpcode		: std_logic_vector(1 downto 0)  := jmpCode_inc;
 	signal w_e_rf 		: std_logic := '0';
 	signal en_opB		: std_logic := '0';
 	signal sel_alu		: std_logic := '0';
    signal en_Z			: std_logic := '0';
	signal stack_code		: std_logic_vector(1 downto 0) := (others => '0');
	signal opc_code: std_logic_vector(1 downto 0) := opcCode_zero;
	signal en_rcall		: std_logic := '0';
	signal w_e_dm		: std_logic := '0';	
	   
    -- outputs of Regfile
 	signal data_opa 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_opb 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal addr_Z		: std_logic_vector (9 downto 0) := (others => '0');

	-- inputs of instr_exec
	signal w_e_dm_IF	: std_logic := '0';
	signal w_e_rf_IF	: std_logic := '1';
	signal mux_jmpcode	: std_logic_vector(1 downto 0) := jmpCode_inc;
	signal mux_data_opc	: std_logic := '0';
	signal mux_stack_code	: std_logic_vector(1 downto 0) := (others => '0');

	--outputs of instr_exec
    signal addr_opa_IE  : std_logic_vector(4 downto 0) := (others => '0');
    signal addr_opb_IE  : std_logic_vector(4 downto 0) := (others => '0');
    signal addr_Z_IE	: std_logic_vector (9 downto 0) := (others => '0');
    signal data_opa_IE	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal data_opb_IE	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');    
    signal opcode_IE	: std_logic_vector(3 downto 0) := (others => '0');
    signal jmpcode_IE	: std_logic_vector(1 downto 0) := jmpCode_inc;
	signal mask_sreg_IE	: STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
	signal stack_op_IE	: std_logic_vector(1 downto 0) := (others => '0');	
	signal addr_pm_IE	: std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal sel_alu_IE	: std_logic := '0';
	signal en_opB_IE	: std_logic := '1';
	signal w_e_rf_IE	: std_logic := '0';    
    signal en_Z_IE		: std_logic := '0';
	signal data_opc_IE	: std_logic := '0';
	signal sreg_curr 	: std_logic_vector (1 downto 0) := (others => '0');
	signal en_rcall_IE	: std_logic := '0';
	signal w_e_dm_IE	: std_logic := '0';
	signal addr_rel_IE	: std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');	
	
	-- output of pipe_WB
	signal data_alu_WB 	: STD_LOGIC_VECTOR (7 downto 0):= (others => '0');
    signal data_dm_WB	: STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    signal addr_opa_WB	: std_logic_vector (4 downto 0);
    signal w_e_rf_WB	: std_logic := '0';
    signal sel_alu_WB	: std_logic := '0';
    signal jmpcode_WB	: std_logic_vector(1 downto 0) := jmpCode_inc;
    signal addr_rel_WB	: std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');    
	
	-- output of fw_logic_IE
	signal data_opa_fw_IE: std_logic_vector(7 downto 0) := (others => '0');
	signal data_opb_fw_IE: std_logic_vector(7 downto 0) := (others => '0');	
	signal addr_Z_fw_IE	: std_logic_vector(9 downto 0) := (others => '0');		
	
	-- output of fw_logic_IF
	signal data_opa_fw: std_logic_vector(7 downto 0) := (others => '0');
	signal data_opb_fw: std_logic_vector(7 downto 0) := (others => '0');
	signal addr_Z_fw	: std_logic_vector(9 downto 0) := (others => '0');	
	
	-- output of ALU
	signal data_alu 	: std_logic_vector (7 downto 0) := (others => '0');
	signal state_alu 	: std_logic_vector (1 downto 0) := (others => '0');  
  
	-- output of datamemory
	signal data_dm_out	: std_logic_vector (PMADDR_WIDTH-1 downto 0);  
  
	-- output of prog_jmp
	signal jmpcode_PJ	: std_logic_vector(1 downto 0) := jmpCode_inc;
	signal sreg_new		: STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
		
	
	signal flush_IE		: std_logic := '1';
	signal carry		: std_logic := '0';
	signal mux_alu_dm	: std_logic_vector (7 downto 0) := (others => '0');
 	signal mux_data_dm	: std_logic_vector (PMADDR_WIDTH-1 downto 0);
	signal mux_opb_opim	: std_logic_vector (7 downto 0) := (others => '0');
	signal mux_Z_AddrB	: std_logic_vector(9 downto 0) := (others => '0');
		
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component clk_wiz_0
	port(
	clk_in1           : in     std_logic;
	clk_out1          : out    std_logic;
	reset             : in     std_logic;
	locked            : out    std_logic);
  end component;

	ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
	ATTRIBUTE SYN_BLACK_BOX OF clk_wiz_0 : COMPONENT IS TRUE;

	ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
	ATTRIBUTE BLACK_BOX_PAD_PIN OF clk_wiz_0 : COMPONENT IS "clk_in1,clk_out1,reset,locked";

  component prog_cnt
    port (
		clk   			: in  std_logic := '0';
		reset 			: in  std_logic := '0';
		jmpcode_IE		: in  std_logic_vector(1 downto 0) := jmpCode_inc;
		jmpcode_WB		: in  std_logic_vector(1 downto 0) := jmpCode_inc;
		addr_abs		: in  unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
		addr_out		: out  unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
		addr_rel_out	: out  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
		addr_rel_WB		: in  unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
		instr_out		: out STD_LOGIC_VECTOR (15 downto 0):= (others => '0'));
  end component;

   
  component instr_exec
    port (
		clk   			: in std_logic := '0';    

		addr_opa_in		: in STD_LOGIC_VECTOR (4 downto 0);
		addr_opa_out	: out STD_LOGIC_VECTOR (4 downto 0);
		addr_opb_in		: in STD_LOGIC_VECTOR (4 downto 0);    
		addr_opb_out	: out STD_LOGIC_VECTOR (4 downto 0);
		addr_Z_in		: in std_logic_vector (9 downto 0);
		addr_Z_out		: out std_logic_vector (9 downto 0);		
		addr_rel_out	: out  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
		addr_rel_in		: in  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
        
    	opcode_in		: in std_logic_vector(3 downto 0);
		opcode_out		: out std_logic_vector(3 downto 0);
		jmpcode_in		: in std_logic_vector(1 downto 0) := jmpCode_inc;
		jmpcode_out		: out std_logic_vector(1 downto 0) := jmpCode_inc;
		mask_sreg_in	: in STD_LOGIC_VECTOR (1 downto 0)	:= (others => '0');
		mask_sreg_out	: out STD_LOGIC_VECTOR (1 downto 0)	:= (others => '0');
		stack_op_in		: in std_logic_vector(1 downto 0);
		
		data_opa_in		: in STD_LOGIC_VECTOR (7 downto 0);
		data_opa_out	: out STD_LOGIC_VECTOR (7 downto 0);
		data_opb_in		: in STD_LOGIC_VECTOR (7 downto 0);
		data_opb_out	: out STD_LOGIC_VECTOR (7 downto 0);
		data_opc_in		: in std_logic;
		data_opc_out	: out std_logic;
		addr_pm_in		: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);-- used as data (store)
		addr_pm_out		: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
				
		sreg_in			: in std_logic_vector(1 downto 0)	:= (others => '0');
		sreg_out		: out std_logic_vector(1 downto 0)	:= (others => '0');
    	
		w_e_rf_in		: in std_logic;
		w_e_rf_out		: out std_logic;		
		w_e_dm_in		: in std_logic;
		w_e_dm_out		: out std_logic;
    
		sel_alu_in		: in std_logic;
		sel_alu_out		: out std_logic;
		en_opB_in		: in std_logic;
		en_opB_out		: out std_logic;
		en_rcall_in		: in std_logic;
		en_rcall_out	: out std_logic;
		en_Z_in			: in std_logic;
		en_Z_out		: out std_logic
	
    );
  end component; 
   
  
  component fw_logic
  port (
		w_e_WB		: in std_logic := '0';
		en_opb		: in std_logic := '0';
		en_Z		: in std_logic := '0';		
		
		data_WB		: in std_logic_vector(7 downto 0);
		data_opa_in	: in std_logic_vector(7 downto 0);
		data_opb_in	: in std_logic_vector(7 downto 0);
		addr_Z_in	: in std_logic_vector(9 downto 0);
		
		addr_opa	: in std_logic_vector(4 downto 0);
		addr_opb	: in std_logic_vector(4 downto 0);
		addr_WB		: in std_logic_vector(4 downto 0);
		
		data_opa_out: out std_logic_vector(7 downto 0);
		data_opb_out: out std_logic_vector(7 downto 0);
		addr_Z_out	: out std_logic_vector(9 downto 0)		
  ); 
  end component; 
  
   
  component pipe_WB
  port (
    clk   			: in std_logic := '0';
    
    addr_opa_in		: in std_logic_vector (4 downto 0);
    addr_opa_out	: out std_logic_vector (4 downto 0);

	addr_rel_out	: out  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_rel_in		: in  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');    

    alu_in			: in STD_LOGIC_VECTOR (7 downto 0):= (others => '0');    
    alu_out 		: out STD_LOGIC_VECTOR (7 downto 0):= (others => '0');    
    dm_in			: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');
    dm_out			: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0):= (others => '0');    
    
    w_e_in			: in std_logic;
    w_e_out			: out std_logic;    
    
    sel_alu_in		: in std_logic;
    sel_alu_out		: out std_logic;
    jmpcode_in		: in std_logic_vector(1 downto 0) := jmpCode_inc;
    jmpcode_out		: out std_logic_vector(1 downto 0) := jmpCode_inc
  );
  end component;
   
   
  component data_mem
    port (
		clk 	: in STD_LOGIC;
		reset	: in STD_LOGIC;
		w_e		: in std_logic;
		addr_in : in STD_LOGIC_VECTOR (9 downto 0);
		data_in	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
		data_out: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
		pinb 	: in STD_LOGIC_VECTOR (7 downto 0);
		pinc 	: in STD_LOGIC_VECTOR (7 downto 0);
		pind 	: in STD_LOGIC_VECTOR (4 downto 0);
		portb 	: out STD_LOGIC_VECTOR (7 downto 0);
		portc 	: out STD_LOGIC_VECTOR (7 downto 0);         
		segen 	: out STD_LOGIC_VECTOR (3 downto 0);
		segcont : out STD_LOGIC_VECTOR (7 downto 0)
		);
  end component;  
  
   
  component decoder
    port (
      instr         : in  std_logic_vector(15 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(5 downto 0);
      opcode        : out std_logic_vector(3 downto 0);
      w_e_rf   		: out std_logic;
      w_e_dm 		: out std_logic;
	  en_rcall		: out std_logic;
      mask_sreg     : out std_logic_vector(1 downto 0)	:= (others => '0');
      jmpcode		: out std_logic_vector(1 downto 0) 	:= jmpCode_inc;
      en_opB 		: out std_logic;
      sel_alu 		: out std_logic;
      data_opim		: out std_logic_vector(7 downto 0);
	  en_Z			: out std_logic;
	  stack_code		: out std_logic_vector(1 downto 0);
	  opc_code		: out std_logic_vector(1 downto 0));
  end component;
  
  
  component prog_jmp
	port(
		opcode 		: in std_logic_vector(1 downto 0) 	:= (others => '0');
		state_alu	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		mask_sreg	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		sreg_curr	: in std_logic_vector(1 downto 0) 	:= (others => '0');
		sreg_new	: out std_logic_vector(1 downto 0) 	:= (others => '0');
		jmpcode_in	: in std_logic_vector(1 downto 0) 	:= jmpCode_inc;
		jmpcode_out	: out std_logic_vector(1 downto 0) 	:= jmpCode_inc);
  end component;
  
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      w_e   		: in  std_logic;
      addr_opa_w    : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);      
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opim     : in  STD_LOGIC_VECTOR (7 downto 0);
      addr_Z      	: out  STD_LOGIC_VECTOR (9 downto 0));
  end component;


  component ALU
    port (
      opcode 		: in STD_LOGIC_VECTOR (3 downto 0) 	:= (others => '0');
      OPA 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      OPB 			: in STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '0');
      OPCONST		: in STD_LOGIC 						:= '0';
      RES 			: out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
      state_alu		: out STD_LOGIC_VECTOR (1 downto 0)	:= (others => '0'));
  end component;


begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  clk_wiz_0_1 : clk_wiz_0
    port map (
		clk_in1		=> clk_in,
		clk_out1	=> clk,
		reset		=> reset,
		locked		=> locked
    );
  --clk <= clk_in;


  fw_logic_IF : fw_logic
	port map (
		w_e_WB		=> w_e_rf_WB,
		en_opb		=> en_opB,
		en_Z		=> en_Z,
		
		data_WB		=> mux_alu_dm,
		data_opa_in	=> data_opa,
		data_opb_in	=> mux_opb_opim,
		addr_Z_in	=> mux_Z_AddrB,
		
		addr_opa	=> addr_opa,
		addr_opb	=> addr_opb(4 downto 0),
		addr_WB		=> addr_opa_WB,
		
		data_opa_out=> data_opa_fw,
		data_opb_out=> data_opb_fw,
		addr_Z_out	=> addr_Z_fw
	);

    
  fw_logic_IE : fw_logic
	port map (
		w_e_WB		=> w_e_rf_WB,
		en_opb		=> en_opB_IE,
		en_Z		=> en_Z_IE,
		
		data_WB		=> mux_alu_dm,
		data_opa_in	=> data_opa_IE,
		data_opb_in	=> data_opb_IE,
		addr_Z_in	=> addr_Z_IE,
		
		addr_opa	=> addr_opa_IE,
		addr_opb	=> addr_opb_IE,
		addr_WB		=> addr_opa_WB,
		
		data_opa_out=> data_opa_fw_IE,
		data_opb_out=> data_opb_fw_IE,
		addr_Z_out	=> addr_Z_fw_IE
	);
  

  -- instance "prog_cnt_1"
  prog_cnt_1: prog_cnt
    port map (
      clk   		=> clk,
      reset 		=> reset,
      jmpcode_IE	=> jmpcode_PJ,
      jmpcode_WB	=> jmpcode_WB,
      addr_abs		=> unsigned(data_dm_WB),
      addr_out		=> addr_pm,
      addr_rel_out	=> addr_rel_IF,
      addr_rel_WB	=> unsigned(addr_rel_WB),
      instr_out		=> instr);
  
      
  instr_exec_1 : instr_exec
	port map(
		clk				=> clk,    

		addr_opa_in		=> addr_opa,		
		addr_opa_out	=> addr_opa_IE,			
		addr_opb_in		=> addr_opb(4 downto 0),
		addr_opb_out	=> addr_opb_IE,
		addr_Z_in		=> addr_Z_fw,
		addr_Z_out		=> addr_Z_IE,			
		addr_rel_in		=> addr_rel_IF,
		addr_rel_out	=> addr_rel_IE,
				
		data_opa_in		=> data_opa_fw,			
		data_opa_out	=> data_opa_IE,
		data_opb_in		=> data_opb_fw,      
		data_opb_out	=> data_opb_IE,	
		data_opc_in		=> mux_data_opc,		
		data_opc_out	=> data_opc_IE,
		addr_pm_in		=> std_logic_vector(addr_pm),			--used as data
		addr_pm_out		=> addr_pm_IE,
		
		w_e_rf_in		=> w_e_rf_IF,
		w_e_rf_out		=> w_e_rf_IE,		
		w_e_dm_in		=> w_e_dm_IF,
		w_e_dm_out		=> w_e_dm_IE,

		stack_op_in		=> mux_stack_code,

		opcode_in		=> opcode,
		opcode_out		=> opcode_IE,
		jmpcode_in		=> mux_jmpcode,
		jmpcode_out		=> jmpcode_IE,
		mask_sreg_in	=> mask_sreg,
		mask_sreg_out	=> mask_sreg_IE,
		
		sreg_in			=> sreg_new,
		sreg_out		=> sreg_curr,
		
		sel_alu_in		=> sel_alu,
		sel_alu_out		=> sel_alu_IE,
		en_opB_in 		=> en_opB,
		en_opB_out 		=> en_opB_IE,
		en_rcall_in		=> en_rcall,
		en_rcall_out	=> en_rcall_IE,
		en_Z_in			=> en_Z,
		en_Z_out		=> en_Z_IE
	  );
      
      
  -- instance "pipe_WB_1"
  pipe_WB_1 : pipe_WB
  port map (
		clk   			=> clk,	
		addr_opa_in 	=> addr_opa_IE,
		addr_opa_out 	=> addr_opa_WB,    
		addr_rel_in		=> addr_rel_IE,
		addr_rel_out	=> addr_rel_WB,
		alu_in			=> data_alu,
		alu_out 		=> data_alu_WB,
		dm_in			=> data_dm_out,
		dm_out			=> data_dm_WB,      
		w_e_in			=> w_e_rf_IE,
		w_e_out			=> w_e_rf_WB,
		sel_alu_in		=> sel_alu_IE,
		sel_alu_out		=> sel_alu_WB,
		jmpcode_in		=> jmpcode_PJ,
		jmpcode_out		=> jmpcode_WB
  );
  
       
  -- instance "datamem_1"
  data_mem_1: data_mem
    port map (
	  clk      	=> 	clk,
	  reset		=> 	reset,
      addr_in  	=> 	addr_Z_fw_IE,
      data_in	=> 	mux_data_dm,
      data_out  => 	data_dm_out,
      w_e		=> 	w_e_dm_IE,
      pinb		=>  hw_pinb,
      pinc		=>  hw_pinc,
      pind 		=>  hw_pind,
      portb 	=>  hw_portb,
      portc 	=>  hw_portc,           
      segen 	=>  hw_seg_enbl,
      segcont	=>  hw_seg_cont
      );  
  
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      instr         => instr,
      stack_code		=> stack_code,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      opcode        => opcode,
      w_e_rf   		=> w_e_rf,
      w_e_dm		=> w_e_dm,
      en_rcall		=> en_rcall,
      mask_sreg     => mask_sreg,
      opc_code		=> opc_code,
      jmpcode		=> jmpcode,
	  en_opB		=> en_opB,
      sel_alu		=> sel_alu,
      data_opim		=> data_opim,
      en_Z			=> en_Z);


  prog_jmp_1: prog_jmp
	port map(
	  opcode		=> opcode_IE(1 downto 0),
	  state_alu		=> state_alu,
	  
	  sreg_new		=> sreg_new,
	  sreg_curr		=> sreg_curr,
	  mask_sreg		=> mask_sreg_IE,
	  
	  jmpcode_in	=> jmpcode_IE,
	  jmpcode_out	=> jmpcode_PJ	  
	);

  -- instance "Reg_File_1"
  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa_w	=> addr_opa_WB,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb(4 downto 0),
      w_e			=> w_e_rf_WB,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_opim  	=> mux_alu_dm,
      addr_Z		=> addr_Z);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> opcode_IE,
      OPA    		=> data_opa_fw_IE,
      OPB    		=> data_opb_fw_IE,
      OPCONST		=> data_opc_IE,
      RES 			=> data_alu,
      state_alu		=> state_alu);

	-- ++++++++ --
	-- toplevel --
	-- ++++++++ --    
    
    carry <= sreg_new(0);
    
    sel_data_opc:process(opc_code, carry)
    begin
		case opc_code is
			--sub, com
			when opcCode_one	=> 	mux_data_opc <= '1';
			--adc
			when opcCode_carry	=>	mux_data_opc <= carry;
			when others 		=> 	mux_data_opc <= '0';
		end case;
    end process;
    
    
	mux_opb_opim	<= data_opim 	when (en_opB = '0') 				else data_opb;
	mux_data_dm 	<= addr_pm_IE 	when (en_rcall_IE = '1') 			else "0"&data_opa_fw_IE;	
	
	-- fw:addr_dm
	mux_Z_AddrB		<= addr_Z		when (en_Z = '1')					else "0000"&addr_opb;	
	
	-- output of wb_pipeline4
	mux_alu_dm 		<= data_alu_WB 	when (sel_alu_WB = '1') 			else data_dm_WB(7 downto 0);
		
	-- flush if jump (branch, ret, rcall, rjmp)
	flush_IE 		<= jmpcode_PJ(1);
	mux_jmpcode 	<= jmpcode 		when (flush_IE = '1') 				else jmpCode_inc;
	mux_stack_code 	<= stack_code 	when (flush_IE = '1') 				else (others => '0');
	w_e_rf_IF 		<= (w_e_rf AND flush_IE);
	w_e_dm_IF 		<= (w_e_dm AND flush_IE);
	
	set_reset:process(hw_pind)
	begin
		reset <= '0';
		if hw_pind = "11111" then
			reset <= '1';
		end if;
	end process;
	
	--reset <= ((hw_pind(0) AND hw_pind(1)) AND hw_pind(2) AND (hw_pind(3) AND hw_pind(4)));

end Behavioral;
