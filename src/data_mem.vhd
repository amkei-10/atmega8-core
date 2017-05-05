-------------------------------------------------------------------------------
-- Title      : Data-Memory
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : data_mem.vhd
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

entity data_mem is
	port(
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
end data_mem;


architecture Behavioral of data_mem is

	signal data_out_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	
	--signal pinb_reg : std_logic_vector(7 downto 0) := (others => '0');
	--signal pinc_reg : std_logic_vector(7 downto 0) := (others => '0');
	--signal pind_reg : std_logic_vector(4 downto 0) := (others => '0');
	
	component io_mem
    port (
		clk 	: in STD_LOGIC;
		reset	: in STD_LOGIC;
		w_e		: in std_logic;
		addr_in : in STD_LOGIC_VECTOR (9 downto 0);
		data_in	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
		portb 	: out STD_LOGIC_VECTOR (7 downto 0);
		portc 	: out STD_LOGIC_VECTOR (7 downto 0);         
		segen 	: out STD_LOGIC_VECTOR (3 downto 0);
		segcont : out STD_LOGIC_VECTOR (7 downto 0)
		);
	end component;
	
	
	component ram
	generic( REG_WIDTH : integer;
			 SLOTS	   : integer);
    port (
        clk         : in STD_LOGIC;
        data_in    	: in STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0);
        addr    	: in STD_LOGIC_VECTOR (9 downto 0);
        w_e			: in STD_LOGIC;
        en			: in STD_LOGIC;        
        data_out    : out STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0));        
	end component;	

	attribute dont_touch : string;
	attribute dont_touch of ram : component is "true";
	
begin

	-- instance "iomem_1"
	io_mem_1: io_mem
    port map (
	  clk      	=> 	clk,
	  reset		=> 	reset,
      addr_in  	=> 	addr_in,
      data_in	=> 	data_in,
      w_e		=> 	w_e,
      portb 	=>  portb,
      portc 	=>  portc,           
      segen 	=>  segen,
      segcont	=>  segcont
      );


	-- instance "ram_mem_1"
	ram_1: ram
	generic map ( REG_WIDTH => PMADDR_WIDTH,
				  SLOTS => 1024)
    port map (
	  clk      		=> clk,
      data_in		=> data_in,
      addr  		=> addr_in,
      w_e 			=> w_e,
      en			=> '1',
      data_out   	=> data_out_ram);

	--save_pins:process(clk)
	--begin
		--if clk'event and clk = '1' then
			--pinb_reg <= pinb;
			--pinc_reg <= pinc;
			--pind_reg <= pind;
			--addr_ram <= addr_in;
		--end if;
	--end process;

	
	sel_data_output:process(addr_in, data_out_ram, pinb, pinc, pind)
	begin
		case addr_in is 
			when def_addr_pinb 	=> data_out <= "0"&pinb;	
			when def_addr_pinc 	=> data_out <= "0"&pinc;					
			when def_addr_pind 	=> data_out <= "0000"&pind;
			when others 		=> data_out <= data_out_ram;
		end case;
	end process;	

end Behavioral;
