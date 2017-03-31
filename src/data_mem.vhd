
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.pkg_processor.all;

entity data_mem is
	port(
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
			segcont : out STD_LOGIC_VECTOR (7 downto 0)
	);
end data_mem;


architecture Behavioral of data_mem is

	signal clk_led : std_logic := '0';

	signal addr_ram : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
	signal data_ram_in : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal data_out_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	
	signal portb_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal portc_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	signal segen_reg : STD_LOGIC_VECTOR (3 downto 0) := "0001";
	signal seg0_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg1_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg2_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg3_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal segcont_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
	
	signal sp_curr : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_new : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_op : std_logic_vector(9 downto 0) := (others => '0');


	component blockram
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
	
	component Freq_Div
	generic( div : integer := 65535 );
	--generic( div : integer := 10 );
	port(
		clk_in : in std_logic;
		clk_out : out std_logic);
	end component;
	
begin

	-- instance "blockram_mem_1"
	blockram_low: blockram
	--generic map ( REG_WIDTH => 3 )
	generic map ( REG_WIDTH => PMADDR_WIDTH,
				  SLOTS => 1024)
    port map (
	  clk      		=> clk,
      --data_in		=> data_ram_in(2 downto 0),
      data_in		=> data_in,
      addr  		=> addr_ram,
      w_e 			=> mdec_op(1),
      en			=> '1',
      --data_out   	=> data_out_ram(2 downto 0));
      data_out   	=> data_out_ram(PMADDR_WIDTH-1 downto 0));

--	blockram_middle: blockram
--	generic map ( REG_WIDTH => 3 )
--    port map (
--	  clk      		=> clk,
--      data_in		=> data_ram_in(5 downto 3),
--      addr  		=> addr_ram,
--      w_e 			=> w_e,
--      en			=> '1',
--      data_out   	=> data_out_ram(5 downto 3));

--	blockram_high: blockram
--	generic map ( REG_WIDTH => 3 )
--    port map (
--	  clk      		=> clk,
--      data_in		=> data_ram_in(8 downto 6),
--      addr  		=> addr_ram,
--      w_e 			=> w_e,
--      en			=> '1',
--      data_out   	=> data_out_ram(8 downto 6));

	freq_div_1: Freq_Div
	port map(
		clk_in		=>	clk,
		clk_out		=> 	clk_led
	);


	sel_sp_op:process(mdec_op)
	begin
		case mdec_op is 
			when mdec_op_push | mdec_op_rcall	=> sp_op <= (others => '1');
			when mdec_op_pop 					=> sp_op <= "0000000001";
			when others 						=> sp_op <= (others 	=> '0');
		end case; 
	end process;
	
	
	update_sp_curr:process(clk)
	begin
		if clk'event and clk = '1' then
			sp_curr <= sp_new; 
		end if;
	end process;
	
	sp_new <= std_logic_vector(unsigned(sp_curr) + unsigned(sp_op));
	
	
	set_addr:process(mdec_op, addr_in, sp_curr, sp_new)
	begin
		case mdec_op is 
			--Stack Pointer is post-decremented by 1 after the PUSH/RCALL
			when mdec_op_push | mdec_op_rcall 	=> addr_ram <= sp_curr;
								
			--Stack Pointer is pre-incremented by 1 before the POP/RET
			when mdec_op_pop 					=> addr_ram <= sp_new;
									
			when others 						=> addr_ram <= addr_in;
		end case; 
	end process;
	
	
	sel_data_output:process(addr_ram, data_in, data_out_ram, pinb, pinc, pind)
	begin
		case addr_ram is 
			when def_addr_pinb 	=> data_out <= "0"&pinb;	
			when def_addr_pinc 	=> data_out <= "0"&pinc;					
			when def_addr_pind 	=> data_out <= "0000"&pind;
			--when def_addr_portb | def_addr_portc 	=> data_out <= data_in;
			when others 		=> data_out <= data_out_ram;
		end case;
	end process;
	
	
	data_ram_in <= data_in; 		



	write_ports:process(clk)
	begin
		if clk'event and clk = '1' then
			if mdec_op = mdec_op_st then
				case addr_in is 
					when def_addr_portb => portb_reg <= data_in(7 downto 0);
					when def_addr_portc => portc_reg <= data_in(7 downto 0);
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
	
	portb <= portb_reg;
	portc <= portc_reg;

	set_segs:process(clk, clk_led)
		variable segen_local : bit_vector(3 downto 0) := "0001";
		variable segcont_local : std_logic_vector(7 downto 0) := (others=>'1');
	begin
		if clk'event and clk = '1' and clk_led = '1' then				
				case segen_local is
					when "0001" => 	segcont_local := seg0_reg;
					when "0010" => 	segcont_local := seg1_reg;
					when "0100" => 	segcont_local := seg2_reg;
					when "1000" => 	segcont_local := seg3_reg;
					when others => 	null;
				end case;
					
				segen <= not to_stdlogicvector(segen_local);
				segcont <= not segcont_local;
				
				--arithmetic shift
				segen_local := segen_local rol 1;
		end if;
	end process;
	
end Behavioral;
