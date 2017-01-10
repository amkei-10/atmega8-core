
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

	signal clk_div : std_logic := '0';

	signal addr_ram : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
	signal data_in_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	signal data_out_ram : STD_LOGIC_VECTOR (PMADDR_WIDTH-1 downto 0) := (others => '0');
	
	signal segen_reg : STD_LOGIC_VECTOR (3 downto 0) := "0001";
	signal seg0_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg1_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg2_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal seg3_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal segcont_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	--signal portb_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	--signal portc_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	signal stackpointer : unsigned(9 downto 0) := (others => '1');

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
	generic( div : integer := 100 );
	port(
		clk : in std_logic;
		clk_div : out std_logic);
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
		clk		=>	clk,
		clk_div	=> 	clk_div
	);


	update_stackptr:process(clk)
	begin
		if clk'event and clk = '1' then
			case mdec_op is 
				--PUSH/RCALL
				when mdec_op_rcall | mdec_op_push => 
					stackpointer <= stackpointer-1;
								
				--POP/RET
				when mdec_op_ret | mdec_op_pop =>
					--if not (stackpointer = "1111111111") then
						stackpointer <= stackpointer+1;
					--end if;

				when others => null;
			end case; 
		end if;
	end process;
	
	
	set_addr:process(mdec_op, addr_in,stackpointer)
	begin
		case mdec_op is 
			--Stack Pointer is post-decremented by 1 after the PUSH/RCALL
			when mdec_op_rcall | mdec_op_push => 
				addr_ram <= std_logic_vector(stackpointer);
								
			--Stack Pointer is pre-incremented by 1 before the POP/RET
			when mdec_op_ret | mdec_op_pop =>
				--if not (stackpointer = "1111111111") then
					addr_ram <= std_logic_vector(stackpointer+1);						
				--else
					--addr_ram <= std_logic_vector(stackpointer);
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
					when "0000111000" => portb <= data_out_ram(7 downto 0);
					when "0000110101" => portc <= data_out_ram(7 downto 0);
					when "0001000000" => segen_reg <= data_out_ram(3 downto 0);
					when "0001000001" => seg0_reg <= data_out_ram(7 downto 0);
					when "0001000010" => seg1_reg <= data_out_ram(7 downto 0);
					when "0001000011" => seg2_reg <= data_out_ram(7 downto 0);
					when "0001000100" => seg3_reg <= data_out_ram(7 downto 0);
					when others => null;
				end case;
			
				case segen_reg is
					when "0001" => segcont_reg <= seg0_reg;
					when "0010" => segcont_reg <= seg1_reg;
					when "0100" => segcont_reg <= seg2_reg;
					when "1000" => segcont_reg <= seg3_reg;
					when others => segcont_reg <= (others => '0');
				end case;
			
			--end if;
		end if;	
	end process;
	
	data_out <= data_out_ram;
	
	--portb <= portb_reg;
	--portc <= portc_reg;
	segen <= not segen_reg;
    segcont <= not segcont_reg;

--	set_segs:process(clk)
--		variable segen_local : std_logic_vector(3 downto 0) := "0001";
--	begin
--		if clk'event and clk = '1' then
--			if clk_div = '1' then
			
--				for i in 3 downto 1 loop
--					segen_local(i) := segen_local(i-1);
--				end loop;
				
--				segen_local(0) := '0';
			
--				if segen_local = "0000" then
--					segen_local := "0001";
--				end if;
				
--				case segen_local is
--					when "0001" => segcont_reg <= seg0_reg;
--					when "0010" => segcont_reg <= seg1_reg;
--					when "0100" => segcont_reg <= seg2_reg;
--					when "1000" => segcont_reg <= seg3_reg;
--					when others => segcont_reg <= (others => '0');
--				end case;
					
--				segen <= not segen_local;
--				segcont <= not segcont_reg;
--			end if;
--		end if;
--	end process;
	
end Behavioral;
