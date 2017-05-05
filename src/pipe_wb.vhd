-------------------------------------------------------------------------------
-- Title      : Pipelinestage Writeback
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : pipe_wb.vhd
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

entity pipe_wb is
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
end pipe_wb;


architecture Behavioral of pipe_wb is
begin

	process(clk)
	begin
		if clk'event and clk = '1' then 		
			addr_opa_out 	<= addr_opa_in;
			dm_out			<= dm_in;
			alu_out			<= alu_in;
			sel_alu_out		<= sel_alu_in;
			w_e_out 		<= w_e_in;
			jmpcode_out		<= jmpcode_in;
			addr_rel_out	<= addr_rel_in;
		end if;
	end process;

end Behavioral;
