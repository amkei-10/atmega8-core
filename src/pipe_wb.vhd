----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:30:37 PM
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

entity pipe_wb is
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
end pipe_wb;


architecture Behavioral of pipe_wb is
	signal addr_opa_wb 	: std_logic_vector(4 downto 0) := (others => '0');
	signal w_e_wb		: bit := '0';
	--signal state_sreg	: std_logic_vector(2 downto 0) := (others => '0');
begin

	process(clk)
		variable state_sreg : std_logic_vector(2 downto 0) := (others => '0');
	begin
		if clk'event and clk = '1' then 		
			--addr_opa_out 	<= addr_opa_in;
			addr_opa_wb		<=  addr_opa_in;
			dm_out			<= dm_in;
			alu_out			<= alu_in;
			sel_alu_out		<= sel_alu_in;
			w_e_out 		<= w_e_in;
			w_e_wb			<= w_e_in;
			jmpcode_out		<= jmpcode_in;
			flush_out		<= flush_in;
			state_sreg 		:= (state_alu_in and mask_sreg_in) or (state_sreg and not mask_sreg_in);
			state_sreg_out 	<= state_sreg;
		end if;
	end process;


	--set_sreg:process(state_sreg, state_alu_in, mask_sreg_in)
	--begin
		--state_sreg <= (state_alu_in and mask_sreg_in) or (state_sreg and not mask_sreg_in);
	--end process;

	--write_sreg: process (state_alu_in, mask_sreg_in)
	--begin
	  --if clk'event and clk = '1' then  -- rising clock edge
		--if reset = '1' then
			--state_sreg <= "00000000";
		--else
			--state_sreg <= (state_alu_in and mask_sreg_in) or (state_sreg and not mask_sreg_in);
		--end if;
	  --end if;
	--end process write_sreg;

  
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
	cmp_data_addr := addr_opb_in xor addr_opa_wb;	
	case (cmp_data_addr) is
		when "00000" =>
			sel_opb_fw <= sel_opb_in;
		when others =>
			sel_opb_fw <= '0';
	end case;	
  end process;

end Behavioral;
