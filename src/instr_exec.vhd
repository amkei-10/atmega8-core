-------------------------------------------------------------------------------
-- Title      : Pipelinestage Instruction Exec, Stackpointhandler
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : instr_exec.vhd
-- Author     : Mario Kellner  <s9mokell@net.fh-jena.de>
-- Company    : 
-- Created    : 2016/2017
-- Platform   : Linux / Vivado 2014.4
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.pkg_processor.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_exec is
  port (
    clk   			: in std_logic := '0';    

    addr_opa_in		: in STD_LOGIC_VECTOR (4 downto 0);
    addr_opa_out	: out STD_LOGIC_VECTOR (4 downto 0);				
    addr_opb_in		: in STD_LOGIC_VECTOR (4 downto 0);    
    addr_opb_out	: out STD_LOGIC_VECTOR (4 downto 0);
    addr_Z_in		: in std_logic_vector(9 downto 0);
    addr_Z_out		: out std_logic_vector(9 downto 0);	
    
    addr_rel_out	: out  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_rel_in		: in  std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
        
    opcode_in		: in std_logic_vector(3 downto 0);
    opcode_out		: out std_logic_vector(3 downto 0);
    jmpcode_in		: in std_logic_vector(1 downto 0) := jmpCode_inc;
    jmpcode_out		: out std_logic_vector(1 downto 0) := jmpCode_inc;
    mask_sreg_in	: in STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
    mask_sreg_out	: out STD_LOGIC_VECTOR (1 downto 0):= (others => '0');
	stack_op_in		: in std_logic_vector(1 downto 0);	
	
    data_opa_in		: in STD_LOGIC_VECTOR (7 downto 0);
    data_opa_out	: out STD_LOGIC_VECTOR (7 downto 0);
    data_opb_in		: in STD_LOGIC_VECTOR (7 downto 0);
    data_opb_out	: out STD_LOGIC_VECTOR (7 downto 0);				-- also used for jmp-values @see decoder.vhd
    data_opc_in	: in std_logic;
    data_opc_out: out std_logic;
    addr_pm_in		: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);	-- used as data (store)
    addr_pm_out		: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);	-- used as data (store)
    
    sreg_in			: in std_logic_vector(1 downto 0):= (others => '0');
    sreg_out		: out std_logic_vector(1 downto 0):= (others => '0');
        
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
end instr_exec;


architecture Behavioral of instr_exec is
	signal sp_curr : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_new : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_op : std_logic_vector(9 downto 0) := (others => '0');
	signal addr_dm : std_logic_vector(9 downto 0) := (others => '0');
begin
  process(clk)
  begin  -- process count
    if clk'event and clk = '1' then 
	
		addr_opa_out 	<= addr_opa_in;
		addr_opb_out 	<= addr_opb_in;
		addr_Z_out 		<= addr_dm;		
		addr_rel_out	<= addr_rel_in;		
		
		data_opa_out 	<= data_opa_in;
		data_opb_out 	<= data_opb_in;
		data_opc_out	<= data_opc_in;
		addr_pm_out 	<= addr_pm_in;
		
		sreg_out		<= sreg_in;
		
		en_opB_out 		<= en_opB_in;
		sel_alu_out 	<= sel_alu_in;
		en_Z_out 		<= en_Z_in;
		en_rcall_out	<= en_rcall_in;
		
		opcode_out 		<= opcode_in;		
		jmpcode_out		<= jmpcode_in;
		
		mask_sreg_out 	<= mask_sreg_in;
		
		w_e_rf_out 		<= w_e_rf_in;		
		w_e_dm_out		<= w_e_dm_in;

		sp_curr 		<= sp_new;
    end if;
  end process;
  

  	sel_sp_op:process(stack_op_in)
	begin
		case stack_op_in is 			
			when stackOP_push	=> sp_op <= (others => '1');
			when stackOP_pop	=> sp_op <= "0000000001";
			when others 		=> sp_op <= (others	=> '0');
		end case; 
	end process;
		
	sp_new <= std_logic_vector(unsigned(sp_curr) + unsigned(sp_op));
	
	set_addr:process(stack_op_in, addr_Z_in, sp_curr, sp_new)
	begin
		case stack_op_in is 
			--Stack Pointer is post-decremented by 1 after the PUSH/RCALL
			when stackOP_push 	=> addr_dm <= sp_curr;
			--Stack Pointer is pre-incremented by 1 before the POP/RET
			when stackOP_pop	=> addr_dm <= sp_new;									
			when others 		=> addr_dm <= addr_Z_in;
		end case; 
	end process;
  
end Behavioral;
