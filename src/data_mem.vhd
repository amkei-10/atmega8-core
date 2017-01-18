
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
	signal data_in_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal data_out_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	
	signal pinb_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal pinc_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal pind_reg : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
	
	signal portb_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal portc_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	--signal segen_reg : STD_LOGIC_VECTOR (3 downto 0) := "0001";
	signal seg0_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg1_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg2_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg3_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal segcont_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
	
	signal sp_curr : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_new : std_logic_vector(9 downto 0) := (others => '1');
	signal sp_op : std_logic_vector(9 downto 0) := (others => '0');
	
	signal w_e : std_logic;

	component blockram
    port (
        clk         : in STD_LOGIC;
        data_in    	: in STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0);
        addr    	: in STD_LOGIC_VECTOR (9 downto 0);
        w_e			: in STD_LOGIC;
        en			: in STD_LOGIC;        
        data_out    : out STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0));
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
	blockram_1: blockram
    port map (
	  clk      		=> clk,
      data_in		=> data_in_ram,
      addr  		=> addr_ram,
      w_e 			=> w_e,
      en			=> '1',
      data_out   	=> data_out_ram);

	freq_div_1: Freq_Div
	port map(
		clk_in		=>	clk,
		clk_out	=> 	clk_led
	);


	sel_sp_op:process(mdec_op)
	begin
		case mdec_op is 
			when mdec_op_rcall | mdec_op_push => sp_op <= (others => '1');
			when mdec_op_ret | mdec_op_pop => sp_op <= "0000000001";
			when others => sp_op <= (others => '0');
		end case; 
	end process;
	
	
	update_sp_curr:process(clk)
	begin
		if clk'event and clk = '1' then
			sp_curr <= sp_new; 
		end if;
	end process;
	
	sp_new <= std_logic_vector(unsigned(sp_curr) + unsigned(sp_op));
	
	
	set_addr:process(mdec_op, addr_in,sp_curr, sp_new)
	begin
		case mdec_op is 
			--Stack Pointer is post-decremented by 1 after the PUSH/RCALL
			when mdec_op_rcall | mdec_op_push => addr_ram <= sp_curr;
								
			--Stack Pointer is pre-incremented by 1 before the POP/RET
			when mdec_op_ret | mdec_op_pop =>
				--if not (sp_post = "1111111111") then
					addr_ram <= sp_new;						
				--else
					--addr_ram <= std_logic_vector(sp_post);
				--end if;						
			when others => addr_ram <= addr_in;
		end case; 
	end process;
	
	
	sel_data_in:process(addr_in, data_in, pinb, pinc, pind, mdec_op(2))
	begin
		case addr_in is
			when "0000110110" 	=> data_in_ram <= "0"&pinb; 	w_e <= '1';
			when "0000110011" 	=> data_in_ram <= "0"&pinc; 	w_e <= '1';
			when "0000110000" 	=> data_in_ram <= "0000"&pind; 	w_e <= '1';
			when others 		=> data_in_ram <= data_in; 		w_e <= mdec_op(2);
		end case;
	end process;
	

	--write_sfreg:process(addr_in, data_out_ram)
	write_sfreg:process(clk)
	begin
		if clk'event and clk = '1' then
			--if mdec_op(2) = '1' then
				case addr_in is 
					when "0000111000" => portb_reg <= data_out_ram(7 downto 0);
					when "0000110101" => portc_reg <= data_out_ram(7 downto 0);
					--when "0001000000" => segen_reg <= data_out_ram(3 downto 0);
					when "0001000001" => seg0_reg <= data_out_ram(7 downto 0);
					when "0001000010" => seg1_reg <= data_out_ram(7 downto 0);
					when "0001000011" => seg2_reg <= data_out_ram(7 downto 0);
					when "0001000100" => seg3_reg <= data_out_ram(7 downto 0);
					when others => null;
				end case;
			--end if;
		end if;	
	end process;
	
	data_out <= data_out_ram;
	
	portb <= portb_reg;
	portc <= portc_reg;
	
	--pinb_reg <= pinb;
	--pinc_reg <= pinc;
	--pind_reg <= pind;
	
	--segen <= not segen_reg;
    --segcont <= not segcont_reg;

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
				
				--shift left arithmetic
				segen_local := segen_local rol 1;
		end if;
	end process;
	
end Behavioral;
