----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/_p33/_p3015 08:30:37 PM
-- Design Name: 
-- Module Name: prog_cnt - Behavioral
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
    --addr_opa_out2	: out STD_LOGIC_VECTOR (4 downto 0);				
    addr_opb_in		: in STD_LOGIC_VECTOR (5 downto 0);    
    addr_opb_out	: out STD_LOGIC_VECTOR (5 downto 0);
    addr_Z_in		: in std_logic_vector(9 downto 0);
    addr_Z_out		: out std_logic_vector(9 downto 0);	
    
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
    data_opb_out	: out STD_LOGIC_VECTOR (7 downto 0);				-- also used for jmp-values @see decoder.vhd
    addr_pm_in		: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);	-- used as data (store)
    addr_pm_out		: out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);	-- used as data (store)
        
    w_e_in			: bit;
    w_e_out			: out bit;
    
    sel_alu_in		: in bit;
    sel_alu_out		: out bit;
    sel_opb_in		: in bit;
	sel_opb_out		: out bit;
    sel_Zaddr_in	: in bit;
	sel_Zaddr_out	: out bit;
	
	sel_opb_fw		: out bit;
    sel_opa_fw		: out bit;
    sel_ZH_fw		: out bit;
    sel_ZL_fw		: out bit    
    );    
end instr_exec;

-- Rudimentaerer Programmzaehler ohne Ruecksetzen und springen...

architecture Behavioral of instr_exec is
  signal addr_opa_p2 	: std_logic_vector(4 downto 0) := (others => '0');
  signal addr_opa_wb 	: std_logic_vector(4 downto 0) := (others => '0');
  signal w_e_p2			: bit := '0';
  signal w_e_wb			: bit := '0';
begin
  process(clk)
  begin  -- process count
    if clk'event and clk = '1' then 
	
		addr_opa_out 	<= addr_opa_in;
		addr_opa_p2 	<= addr_opa_in;
		--addr_opa_out2	<= addr_opa_p2;
		addr_opa_wb 	<= addr_opa_p2;
		addr_opb_out 	<= addr_opb_in;
		addr_Z_out 		<= addr_Z_in;		
		
		data_opa_out 	<= data_opa_in;
		data_opb_out 	<= data_opb_in;
		addr_pm_out 	<= addr_pm_in;
		
		sel_opb_out 	<= sel_opb_in;
		sel_alu_out 	<= sel_alu_in;
		sel_Zaddr_out 	<= sel_Zaddr_in;
		
		opcode_out 		<= opcode_in;		
		jmpcode_out		<= jmpcode_in;
		
		mask_sreg_out 	<= mask_sreg_in;
		mdec_op_out 	<= mdec_op_in;
		
		w_e_out 		<= w_e_in;
		w_e_p2			<= w_e_in;
		w_e_wb			<= w_e_p2;		
    end if;
  end process;


  -- sneaky bug alert (!!!)
  set_opa_fw:process(addr_opa_in, addr_opa_wb, w_e_wb)
	variable cmp_data_addr : std_logic_vector(4 downto 0) := (others => '1');
  begin
	cmp_data_addr := addr_opa_in xor addr_opa_wb;
	
	sel_opa_fw <= '0';	
	case (cmp_data_addr) is
		when "00000" 	=> sel_opa_fw <= w_e_wb;
		when others 	=> null;
	end case;
	
	sel_ZH_fw <= '0';
	sel_ZL_fw <= '0';
	case (addr_opa_wb) is
		when "11111"	=> sel_ZH_fw <= w_e_wb;	--0x31
		when "11110"	=> sel_ZL_fw <= w_e_wb;	--0x30
		when others 	=> null;
	end case;
  end process;
  
  
  set_opb_fw:process(addr_opb_in, addr_opa_wb, sel_opb_in)
	variable cmp_data_addr : std_logic_vector(4 downto 0) := (others => '1');
  begin
	cmp_data_addr := addr_opb_in(4 downto 0) xor addr_opa_wb;
	
	sel_opb_fw <= '0';
	case (cmp_data_addr) is
		when "00000" 	=> sel_opb_fw <= sel_opb_in;
		when others 	=> null;
	end case;	
  end process;
  
  

end Behavioral;
