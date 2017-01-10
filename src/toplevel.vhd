----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:45:28 PM
-- Design Name: 
-- Module Name: toplevel - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use work.pkg_processor.all;
use work.pkg_instrmem.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port (
		--reset  		: in STD_LOGIC;
		clk   		: in STD_LOGIC;
		
		hw_seg_enbl	: out std_logic_vector (3 downto 0) := (others => '0');
		hw_seg_cont	: out std_logic_vector (7 downto 0) := (others => '0');
		
		hw_portb	: out std_logic_vector (7 downto 0) := (others => '0');
		hw_portc	: out std_logic_vector (7 downto 0) := (others => '0');
		
		hw_pinb		: in std_logic_vector (7 downto 0) := (others => '0');
		hw_pinc		: in std_logic_vector (7 downto 0) := (others => '0');
		hw_pind		: in std_logic_vector (4 downto 0) := (others => '0'));		

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

	signal reset		: std_logic; 

	-- outputs of "prog_cnt_1"
  	signal addr_pm 		: unsigned (PMADDR_WIDTH-1 downto 0);

	-- outputs of "prog_mem_1"
	signal Instr 		: STD_LOGIC_VECTOR (15 downto 0);

	-- outputs of "decoder_1"
 	signal 	addr_opa    : std_logic_vector(4 downto 0);
 	signal 	addr_opb    : std_logic_vector(5 downto 0);
 	signal 	data_dcd   	: std_logic_vector(7 downto 0);					-- used for wiring immediate data
 	signal 	OPCODE      : std_logic_vector(4 downto 0);
 	signal 	mask_sreg   : std_logic_vector(7 downto 0);
 	signal 	rel_pc		: std_logic_vector(PMADDR_WIDTH-1 downto 0);
 	signal	abs_jmp		: bit;
 	signal 	w_e_regf 	: bit;
 	--signal 	sel_im 		: std_logic;
 	signal 	sel_ldi		: bit;
 	signal 	sel_alu		: bit;
 	signal 	sel_opb		: bit_vector(2 downto 0);
    signal 	sel_bconst	: bit_vector(1 downto 0);
    signal 	sel_maddr	: bit;
	signal  mdec_op		: std_logic_vector(2 downto 0);
	
	-- outputs of SREG
 	signal state_sreg 	: std_logic_vector (7 downto 0) := (others => '0');
   
    -- outputs of Regfile
 	signal data_opa 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_opb 	: std_logic_vector (7 downto 0) := (others => '0');
 	signal addr_r3x_regf: std_logic_vector (9 downto 0) := (others => '0');
   
	-- output of multiplexer
 	signal data_mux_ldi	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_im	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_alu	: std_logic_vector (7 downto 0) := (others => '0');
 	--signal data_mux_dm	: std_logic_vector (7 downto 0) := (others => '0');
 	signal data_mux_pc	: unsigned (PMADDR_WIDTH-1 downto 0) := (others => '0');
 	signal data_mux_mdec: std_logic_vector (PMADDR_WIDTH-1 downto 0);
	signal data_mux_opb	: std_logic_vector (7 downto 0) := (others => '0');
	signal data_mux_bconst	: std_logic_vector (7 downto 0) := (others => '0');
	signal data_mux_addrio  : std_logic_vector (9 downto 0) := (others => '0');
	
	-- output of ALU
	signal data_alu 	: std_logic_vector (7 downto 0) := (others => '0');
	signal state_alu 	: std_logic_vector (7 downto 0) := (others => '0');
  
	--output of decoder_mem
	--signal addr_r3x_mdec: STD_LOGIC_VECTOR (9 downto 0);
	--signal ram_en		: bit;
	--signal sel_mdec		: bit;
	--signal w_e_memory	: bit;
  
	-- output of datamemory
	signal data_dm		: std_logic_vector (PMADDR_WIDTH-1 downto 0);
  
	--outputs of io_mem
	--signal data_portb	: std_logic_vector (7 downto 0);
	--signal data_portc	: std_logic_vector (7 downto 0);
	--signal data_segen	: std_logic_vector (7 downto 0);
	--signal data_segcont	: std_logic_vector (7 downto 0);
	--signal data_io		: std_logic_vector (7 downto 0);
     
	signal data_opb_alu	: std_logic_vector (7 downto 0);
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component prog_cnt
    port (
      clk   		: in  STD_LOGIC;
      reset 		: in  STD_LOGIC;
      abs_jmp 		: in  bit;
      addr_in		: in unsigned(PMADDR_WIDTH-1 downto 0);      
      addr_out 		: out unsigned (PMADDR_WIDTH-1 downto 0));
  end component;

  component prog_mem
    port (
      addr  		: in  unsigned (PMADDR_WIDTH-1 downto 0);
      Instr 		: out STD_LOGIC_VECTOR (15 downto 0));
  end component;
   
  component data_mem
    port (
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
			segcont : out STD_LOGIC_VECTOR (7 downto 0));
  end component;
  
     
--component decoder_mem
--port ( 
--    w_e_out		: out bit;
--    addr_in 	: in STD_LOGIC_VECTOR (9 downto 0);
--    addr_out	: out STD_LOGIC_VECTOR (9 downto 0);
--    ram_en		: out bit;
--    sel_mdec	: out bit;
--    mdec_op	: in std_logic_vector(2 downto 0));
--  end component;
   
  component decoder
    port (
      Instr         : in  std_logic_vector(15 downto 0);
      state_sreg	: in  std_logic_vector(7 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(5 downto 0);
      OPCODE        : out std_logic_vector(4 downto 0);
      w_e_regf   	: out bit;
      mask_sreg     : out std_logic_vector(7 downto 0);
      rel_pc		: out std_logic_vector(PMADDR_WIDTH-1 downto 0);
      abs_jmp		: out bit;
      --sel_im 		: out std_logic;
      sel_ldi		: out bit;
      sel_alu 		: out bit;
      data_dcd		: out std_logic_vector(7 downto 0);
      sel_opb		: out bit_vector(2 downto 0);
	  sel_bconst	: out bit_vector(1 downto 0);
	  sel_maddr		: out bit;
	  mdec_op		: out std_logic_vector(2 downto 0));
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      w_e   		: in  bit;
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);      
      data_opa      : out STD_LOGIC_VECTOR (7 downto 0);
      data_opb      : out STD_LOGIC_VECTOR (7 downto 0);
      data_ldi      : in  STD_LOGIC_VECTOR (7 downto 0);
      addr_r3x      : out  STD_LOGIC_VECTOR (9 downto 0));
  end component;

  component ALU
    port (
      OPCODE 		: in  STD_LOGIC_VECTOR (4 downto 0);
      OPA    		: in  STD_LOGIC_VECTOR (7 downto 0);
      OPB    		: in  STD_LOGIC_VECTOR (7 downto 0);
      RES 			: out STD_LOGIC_VECTOR (7 downto 0);
      state_alu	    : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "prog_cnt_1"
  prog_cnt_1: prog_cnt
    port map (
      clk   		=> clk,
      reset 		=> reset,
      abs_jmp		=> abs_jmp,
      addr_in  		=> data_mux_pc,
      addr_out 		=> addr_pm);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      addr  	=> addr_pm,      
      Instr 	=> Instr);
      
  -- instance "datamem_1"
  data_mem_1: data_mem
    port map (
	  clk      	=> 	clk,
      addr_in  	=> 	data_mux_addrio,
      data_in	=> 	data_mux_mdec,
      data_out  => 	data_dm,
      mdec_op	=> 	mdec_op,
      pinb		=>  hw_pinb,
      pinc		=>  hw_pinc,
      pind 		=>  hw_pind,
      portb 	=>  hw_portb,
      portc 	=>  hw_portc,           
      segen 	=>  hw_seg_enbl,
      segcont	=>  hw_seg_cont);
  
--  decoder_mem_1 : decoder_mem
--	port map (
--	  mdec_op		=> mdec_op,
--	  w_e_out		=> w_e_memory,	  
--	  addr_in		=> data_mux_addrio,
--	  addr_out		=> addr_r3x_mdec,
--	  ram_en		=> ram_en,
--	  sel_mdec		=> sel_mdec);
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      Instr         => Instr,
      mdec_op		=> mdec_op,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      OPCODE        => OPCODE,
      w_e_regf   	=> w_e_regf,
      mask_sreg     => mask_sreg,
      state_sreg	=> state_sreg,
      rel_pc		=> rel_pc,
      abs_jmp		=> abs_jmp,
	  --sel_im 		=> sel_im,
	  sel_ldi		=> sel_ldi,
      sel_alu		=> sel_alu,
      data_dcd		=> data_dcd,
      sel_opb		=> sel_opb,
      sel_bconst	=> sel_bconst,
      sel_maddr		=> sel_maddr);

  -- instance "Reg_File_1"
  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb(4 downto 0),
      w_e   		=> w_e_regf,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_ldi  	=> data_mux_ldi,
      addr_r3x		=> addr_r3x_regf);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> OPCODE,
      OPA    		=> data_opa,
      OPB    		=> data_opb_alu,
      RES 			=> data_alu,
      state_alu		=> state_alu);

	-- toplevel logic
    
    -- push & pop == 1 means rcall
	data_mux_mdec <= std_logic_vector(addr_pm) when (mdec_op(1 downto 0)  = "11") else "0"&data_opa;  
	--data_mux_im  <= data_dcd when (sel_im = '1') else data_opb; 
	data_mux_ldi <= data_dcd when (sel_ldi = '1') else data_mux_alu;  
	data_mux_alu <= data_alu when (sel_alu = '1') else data_dm(7 downto 0);  
	--data_mux_dm <= data_dm(7 downto 0) when (ram_en = '1') else data_io;	
	data_mux_pc <= unsigned(rel_pc) when (abs_jmp = '0') else unsigned(data_dm);
	data_mux_addrio <= addr_r3x_regf when (sel_maddr = '0') else "0000"&addr_opb;
	
	reset <= hw_pind(0) and hw_pind(1) and hw_pind(2) and hw_pind(3) and hw_pind(4);
	
	--hw_portb<= data_portb;
	--hw_portc<= data_portc;
	--hw_seg_enbl <= data_segen(3 downto 0);
	-- <= data_segcont;
	
	select_opb:process(sel_opb, data_opb, data_dcd)
	begin
		case sel_opb is
			when "000" => data_mux_opb <= data_opb;
			when "001" => data_mux_opb <= not data_opb;
			when "010" => data_mux_opb <= data_dcd;
			when "110" => data_mux_opb <= not data_dcd;
			when others => data_mux_opb <= (others => '0');
		end case;
	end process;
	
	select_bconst:process(sel_bconst, state_sreg(0))
	begin
		case sel_bconst is
			--when "00" => data_mux_bconst <= data_opb;
			when "01" => data_mux_bconst <= "00000001";
			when "10" => data_mux_bconst <= (others => '1');
			when "11" => data_mux_bconst <= "0000000"&state_sreg(0);
			when others => data_mux_bconst <= (others => '0');
		end case;
	end process;
	
	set_opb:process(data_mux_bconst, data_mux_opb)
	begin
		data_opb_alu <= std_logic_vector(unsigned(data_mux_bconst) + unsigned(data_mux_opb));
	end process;
	
	--select_opb:process()
	
	-- purpose: Schreibprozess
	-- type   : sequential
	-- inputs : clk, mask_sreg, Status
	-- outputs: register_speicher
	write_sreg: process (clk)
	begin
	  if clk'event and clk = '1' then  -- rising clock edge
		if hw_pind(0) = '1' then
			state_sreg <= "00000000";
		else
			state_sreg <= (state_alu and mask_sreg) or (state_sreg and not mask_sreg);
		end if;
	  end if;
	end process write_sreg;

	

end Behavioral;
