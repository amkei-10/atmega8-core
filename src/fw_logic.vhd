-------------------------------------------------------------------------------
-- Title      : Forwarding Logic
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : fw_logic.vhd
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


entity fw_logic is
  port (
		signal 	w_e_WB		: in std_logic := '0';
		signal 	en_opb		: in std_logic := '0';
		signal 	en_Z		: in std_logic := '0';		
		
		signal  data_WB		: in std_logic_vector(7 downto 0);
		signal  data_opa_in	: in std_logic_vector(7 downto 0);
		signal  data_opb_in	: in std_logic_vector(7 downto 0);
		signal  addr_Z_in	: in std_logic_vector(9 downto 0);
		
		signal	addr_opa	: in std_logic_vector(4 downto 0);
		signal	addr_opb	: in std_logic_vector(4 downto 0);
		signal	addr_WB		: in std_logic_vector(4 downto 0);
		
		signal  data_opa_out: out std_logic_vector(7 downto 0);
		signal  data_opb_out: out std_logic_vector(7 downto 0);
		signal  addr_Z_out	: out std_logic_vector(9 downto 0)
    );
end fw_logic;


architecture Behavioral of fw_logic is
begin	

	-- OPA
	fw_opa:process(addr_opa, addr_WB, data_opa_in, data_WB, w_e_WB)
		variable cmp_addr : std_logic_vector(5 downto 0) := (others => '1');
	begin
		cmp_addr := (addr_opa xor addr_WB) & (w_e_WB);	
		case cmp_addr is 
			when "000001"	=> 	data_opa_out <= data_WB;
			when others 	=>	data_opa_out <= data_opa_in;
		end case;
	end process;


	-- OPB
	fw_opb:process(addr_opb, addr_WB, data_opb_in, data_WB, en_opb, w_e_WB)
		variable cmp_addr : std_logic_vector(5 downto 0) := (others => '1');
	begin
		cmp_addr := (addr_opb xor addr_WB) & (w_e_WB AND en_opb);	
		case cmp_addr is 
			when "000001"	=> 	data_opb_out <= data_WB;
			when others 	=>	data_opb_out <= data_opb_in;
		end case;
	end process;


	-- Z
	fw_Z:process(addr_WB, addr_Z_in, data_WB, en_Z, w_e_WB)
		variable cmp_addr : std_logic_vector(5 downto 0) := (others => '0');
	begin		
		cmp_addr := (addr_WB) & (w_e_WB AND en_Z);
		addr_Z_out <= addr_Z_in;
		case cmp_addr is
			when "111111"	=> addr_Z_out(9 downto 8) <= data_WB(1 downto 0);
			when "111101"	=> addr_Z_out(7 downto 0) <= data_WB;
			when others 	=> null;
		end case ;		
	end process;
	
end Behavioral;
