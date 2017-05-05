-------------------------------------------------------------------------------
-- Title      : Programcounter, Instruction Fetch
-- Project    : hardCORE
-------------------------------------------------------------------------------
-- File       : prog_cnt.vhd
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

entity prog_cnt is
  port (
    clk   		: in std_logic := '0';
    reset 		: in std_logic := '0';
    jmpcode_IE	: in std_logic_vector(1 downto 0) := jmpCode_inc;    
    jmpcode_WB	: in std_logic_vector(1 downto 0) := jmpCode_inc;
    addr_abs	: in unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_out	: out unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_rel_out: out std_logic_vector (PMADDR_WIDTH-1 downto 0) := (others => '0');
    addr_rel_WB	: in unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
    instr_out	: out STD_LOGIC_VECTOR (15 downto 0) := (others => '0')
    );
end prog_cnt;

-- Programmzaehler mit Ruecksetzen und springen

architecture Behavioral of prog_cnt is

  signal addr		: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
  signal addr_calc	: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
  signal operant_A	: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
  signal operant_B	: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
  
  signal flush_IE	: std_logic;
  signal flush_instr: std_logic := '0';  
  signal instr		: STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
  
  --signal addr_rel_IE	: unsigned(PMADDR_WIDTH-1 downto 0) := (others => '0');
  --signal addr_rel_WB	: unsigned(PMADDR_WIDTH-1 downto 0) := (others => '0');  
  --signal addr_rel		: STD_LOGIC_VECTOR(PMADDR_WIDTH-1 downto 0) := (others => '0');
  
  component prog_mem
	port (
		clk     : in STD_LOGIC;
        data_in	: in STD_LOGIC_VECTOR (15 downto 0);           
        w_e     : in std_logic;
        en      : in std_logic;		   
		addr 	: in unsigned (PMADDR_WIDTH-1 downto 0);
        instr 	: out STD_LOGIC_VECTOR (15 downto 0):= (others => '0'));        
	end component;
  
  	attribute dont_touch : string;
	attribute dont_touch of prog_mem : component is "true";
  
begin

	-- instance "prog_mem_1"
	prog_mem_1: prog_mem
	port map (
	  clk      		=> clk,
      data_in		=> (others => '0'),
      addr  		=> addr,
      w_e 			=> '0',
      en			=> '1',
      instr   		=> instr);


	set_operant_A:process(jmpcode_WB, addr_calc)
	begin
		case jmpcode_WB is
			when jmpCode_abs => operant_A (PMADDR_WIDTH-1 downto 1) <= (others => '0');
								operant_A(0) <= '1';
			when others 	 =>	operant_A <= addr_calc;
		end case;	
	end process set_operant_A;

	
	flush_IE <= jmpcode_IE(1);
	
	
	--set operant for prog_count
	set_operant_B:process(jmpcode_WB, flush_IE, addr_rel_WB, addr_abs)
	begin
		case jmpcode_WB is			
			when jmpCode_rel => operant_B <= addr_rel_WB(PMADDR_WIDTH-2) & addr_rel_WB(PMADDR_WIDTH-2 downto 0);
			when jmpCode_abs => operant_B <= unsigned(addr_abs);
			--set +/-1 depending on flush
			when others 	  => operant_B(PMADDR_WIDTH-1 downto 1) <= (others => '0');
								 operant_B(0)	<= flush_IE;
								 
		end case;
	end process set_operant_B;


	store_addr:process(clk)
	begin
		if clk'event and clk = '1' then     -- rising clock edge	
			if reset = '1' then 
				addr_calc <= (others => '0');
			else
				addr_calc <= addr;
				flush_instr <= (flush_IE);
			end if;
		end if;
	end process;


	addr <= operant_A + operant_B;
  
	addr_rel_out <= instr(9)&instr(9)&instr(9 downto 3) when (instr(13) = '1') else instr(8 downto 0);
	
	addr_out <= addr_calc;
	
	instr_out <= instr when ( flush_instr = '1') else (others => '0');

end Behavioral;
