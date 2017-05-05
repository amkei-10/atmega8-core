-------------------------------------------------------------------------------
-- Title      : IO Memory
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : io_mem.vhd
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

entity io_mem is
	port(
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
end io_mem;


architecture Behavioral of io_mem is

	signal clk_led : std_logic := '0';
	signal segen_reg : STD_LOGIC_VECTOR (3 downto 0) := "0001";
	signal seg0_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg1_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg2_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg3_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

	component Freq_Div
	generic( div : integer := 65535 );
	--generic( div : integer := 4095 );
	port(
		clk_in : in std_logic;
		clk_out : out std_logic);
	end component;	
	
begin
	
	freq_div_1: Freq_Div
	port map(
		clk_in		=>	clk,
		clk_out		=> 	clk_led
	);


	write_ports:process(clk)
	begin
		if clk'event and clk = '1' then
			if reset = '1' then 
				portb <= (others => '0');
				portb <= (others => '0');
				segen_reg <= (others => '0');
				seg0_reg <= (others => '1');
				seg1_reg <= (others => '1');
				seg2_reg <= (others => '1');
				seg3_reg <= (others => '1');
			elsif w_e = '1' then
				case addr_in is 
					when def_addr_portb => portb <= data_in(7 downto 0);
					when def_addr_portc => portc <= data_in(7 downto 0);
					when def_addr_segen => segen_reg <= data_in(3 downto 0);
					when def_addr_seg0 	=> seg0_reg <= data_in(7 downto 0);
					when def_addr_seg1 	=> seg1_reg <= data_in(7 downto 0);
					when def_addr_seg2 	=> seg2_reg <= data_in(7 downto 0);
					when def_addr_seg3 	=> seg3_reg <= data_in(7 downto 0);
					when others => null;
				end case;
			end if;
		end if;	
	end process;
	
	
	set_segs:process(clk, clk_led)
		variable segen_local : bit_vector(3 downto 0) := "1110";
	begin
		if clk'event and clk = '1' and clk_led = '1' then			
				case segen_local is
					when "1110" => 	segcont <= seg0_reg;
					when "1101" => 	segcont <= seg1_reg;
					when "1011" => 	segcont <= seg2_reg;
					when "0111" => 	segcont <= seg3_reg;
					when others => 	segcont <= (others => '0');
				end case;
					
				segen <= to_stdlogicvector(segen_local);
				
				--arithmetic shift
				segen_local := segen_local rol 1;
		end if;
	end process;
	
end Behavioral;
