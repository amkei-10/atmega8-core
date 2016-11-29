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
use work.pkg_datamem.ALL;	-- definitions of selection-codes

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port (
		--reset 	: in STD_LOGIC;
		clk   		: in STD_LOGIC;
		
		hw_seg_enbl	: out std_logic_vector (3 downto 0);
		hw_seg_cont	: out std_logic_vector (7 downto 0);
		
		hw_portb	: out std_logic_vector (7 downto 0);
		hw_portc	: out std_logic_vector (7 downto 0);
		
		hw_pinb		: in std_logic_vector (7 downto 0);
		hw_pinc		: in std_logic_vector (7 downto 0);
		hw_pind		: in std_logic_vector (4 downto 0));

end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  -- outputs of "Program_Counter_1"
  signal addr_pm 			: STD_LOGIC_VECTOR (8 downto 0);

  -- outputs of "prog_mem_1"
  signal Instr 			: STD_LOGIC_VECTOR (15 downto 0);

  -- outputs of "decoder_1"
   signal  	addr_opa    : std_logic_vector(4 downto 0);
   signal  	addr_opb    : std_logic_vector(4 downto 0);
   signal  	data_dcd   	: std_logic_vector(7 downto 0);					-- used for wiring immediate data
   signal  	OPCODE      : std_logic_vector(4 downto 0);
   signal  	mask_sreg   : std_logic_vector(7 downto 0);
   signal 	rel_pc		: std_logic_vector(6 downto 0);
   signal	w_e_memory	: std_logic;
   signal  	w_e_regfile : std_logic;
   signal 	sel_im 		: std_logic;
   signal 	sel_ldi		: std_logic;
   signal 	sel_alu		: std_logic;

   -- outputs of SREG
   signal state_sreg 	: std_logic_vector (7 downto 0) := x"00";
   
   -- outputs of Regfileread_selcode_pind
   signal data_opa 		: std_logic_vector (7 downto 0) := x"00";
   signal data_opb 		: std_logic_vector (7 downto 0) := x"00";
   signal addr_r3x 		: std_logic_vector (9 downto 0) := "0000000000";
   
   -- output of multiplexer
   signal data_mux_ldi	: std_logic_vector (7 downto 0) := x"00";
   signal data_mux_im	: std_logic_vector (7 downto 0) := x"00";
   signal data_mux_alu	: std_logic_vector (7 downto 0) := x"00";
   signal data_mux_dm	: std_logic_vector (7 downto 0) := x"00";
  
   -- output of ALU
   signal data_alu 		: std_logic_vector (7 downto 0) := x"00";
   signal state_alu 	: std_logic_vector (7 downto 0) := x"00";
  
  --output of decoder_mem
  signal sel_memory : std_logic_vector (3 downto 0);
  signal w_e_portb	: std_logic;
  signal w_e_portc	: std_logic;
  signal w_e_dm		: std_logic;
  signal w_e_segen	: std_logic;
  signal w_e_seg0	: std_logic;
  signal w_e_seg1	: std_logic;
  signal w_e_seg2	: std_logic;
  signal w_e_seg3	: std_logic;
  
  -- output of datamemory
  signal data_dm	: std_logic_vector (7 downto 0);
  
  --outputs of io_regs
  signal data_pinb_o	: std_logic_vector (7 downto 0);
  signal data_pinc_o	: std_logic_vector (7 downto 0);
  signal data_pind_o	: std_logic_vector (7 downto 0);
  signal data_portb_o	: std_logic_vector (7 downto 0);
  signal data_portc_o	: std_logic_vector (7 downto 0);
  signal data_segen_o	: std_logic_vector (7 downto 0);
  signal data_seg0_o	: std_logic_vector (7 downto 0);
  signal data_seg1_o	: std_logic_vector (7 downto 0);
  signal data_seg2_o	: std_logic_vector (7 downto 0);
  signal data_seg3_o	: std_logic_vector (7 downto 0);
  
  --hw-input if io regs
  signal data_pinb_i	: std_logic_vector (7 downto 0);
  signal data_pinc_i	: std_logic_vector (7 downto 0);
  signal data_pind_i	: std_logic_vector (7 downto 0);
  
  signal reset			: std_logic;
  
  

  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component Program_Counter
    port (
      reset 		: in  STD_LOGIC;
      clk   		: in  STD_LOGIC;
      addr_pm  		: out STD_LOGIC_VECTOR (8 downto 0);
      rel_pc		: in std_logic_vector(6 downto 0));
  end component;

  component prog_mem
    port (
      addr_pm  		: in  STD_LOGIC_VECTOR (8 downto 0);
      Instr 		: out STD_LOGIC_VECTOR (15 downto 0));
  end component;
   
  component data_mem
    port (
        clk         : in STD_LOGIC;
        reset		: in STD_LOGIC;
        w_e			: in STD_LOGIC;
        data_in    	: in STD_LOGIC_VECTOR (7 downto 0);
        addr_r3x    : in STD_LOGIC_VECTOR (9 downto 0);        
        data_out    : out STD_LOGIC_VECTOR (7 downto 0));
  end component;
  
  component io_reg
    port(clk		: in std_logic;
		 reset		: in std_logic;
		 w_e		: in std_logic;
		 data_in    : in  std_logic_vector(7 downto 0);
		 data_out   : out std_logic_vector (7 downto 0));
  end component;
     
  component decoder_mem
    port ( 
		addr_r3x 	: in STD_LOGIC_VECTOR (9 downto 0);
		w_e_memory	: in std_logic;
		sel_memory	: out std_logic_vector(3 downto 0);
		w_e_portb	: out std_logic;
		w_e_portc	: out std_logic;
		w_e_dm		: out std_logic;
		w_e_segen	: out std_logic;
		w_e_seg0	: out std_logic;
		w_e_seg1	: out std_logic;
		w_e_seg2	: out std_logic;
		w_e_seg3	: out std_logic);
  end component;
   
  component decoder
    port (
      Instr         : in  std_logic_vector(15 downto 0);
      state_sreg	: in  std_logic_vector(7 downto 0);
      addr_opa      : out std_logic_vector(4 downto 0);
      addr_opb      : out std_logic_vector(4 downto 0);
      OPCODE        : out std_logic_vector(4 downto 0);
      w_e_regfile   : out std_logic;
      w_e_memory 	: out std_logic;
      mask_sreg     : out std_logic_vector(7 downto 0);
      rel_pc		: out std_logic_vector(6 downto 0);
      sel_im 		: out std_logic;
      sel_ldi		: out std_logic;
      sel_alu 		: out std_logic;
      data_dcd		: out std_logic_vector(7 downto 0));
  end component;
  
  component Reg_File
    port (
      clk           : in  STD_LOGIC;
      addr_opa      : in  STD_LOGIC_VECTOR (4 downto 0);
      addr_opb      : in  STD_LOGIC_VECTOR (4 downto 0);
      w_e_regfile   : in  STD_LOGIC;
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

  -- instance "Program_Counter_1"
  Program_Counter_1: Program_Counter
    port map (
      reset 	=> reset,
      clk   	=> clk,
      addr_pm  	=> addr_pm,
      rel_pc 	=> rel_pc);

  -- instance "prog_mem_1"
  prog_mem_1: prog_mem
    port map (
      addr_pm  	=> addr_pm,      
      Instr 	=> Instr);
      
  -- instance "data_mem_1"
  data_mem_1: data_mem
    port map (
	  clk      		=> clk,
	  reset 		=> reset,
      data_in		=> data_opa,
      addr_r3x  	=> addr_r3x,
      w_e 			=> w_e_dm,
      data_out   	=> data_dm);
  
  io_reg_portb : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_portb,
	  data_in		=> data_opa,
	  data_out		=> data_portb_o);
	  
  io_reg_portc : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_portc,
	  data_in		=> data_opa,
	  data_out		=> data_portc_o);
	  
  io_reg_pinb : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e	        => '1',
	  data_in		=> hw_pinb,
	  data_out		=> data_pinb_o);
	  
  io_reg_pinc : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e	        => '1',
	  data_in		=> hw_pinc,
	  data_out		=> data_pinc_o);

  io_reg_pind : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e	        => '1',
	  data_in		=> "000"&hw_pind,
	  data_out		=> data_pind_o);

  io_reg_segen : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_portc,
	  data_in		=> data_opa,
	  data_out		=> data_segen_o);
	  
	io_reg_seg0 : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_seg0,
	  data_in		=> data_opa,
	  data_out		=> data_seg0_o);
	  
	io_reg_seg1 : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_seg1,
	  data_in		=> data_opa,
	  data_out		=> data_seg1_o);
	  
	io_reg_seg2 : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_seg2,
	  data_in		=> data_opa,
	  data_out		=> data_seg2_o);
	  
	io_reg_seg3 : io_reg
	port map (
	  clk 			=> clk,
	  reset			=> reset,
	  w_e			=> w_e_seg3,
	  data_in		=> data_opa,
	  data_out		=> data_seg3_o);


  decoder_mem_1 : decoder_mem
	port map (
	  addr_r3x		=> addr_r3x,	  
	  sel_memory	=> sel_memory,
	  w_e_dm		=> w_e_dm,
	  w_e_portb		=> w_e_portb,
	  w_e_portc		=> w_e_portc,
	  w_e_memory	=> w_e_memory,
	  w_e_segen		=> w_e_segen,
	  w_e_seg0		=> w_e_seg0,
	  w_e_seg1		=> w_e_seg1,
	  w_e_seg2		=> w_e_seg2,
	  w_e_seg3		=> w_e_seg3);
  
  -- instance "decoder_1"
  decoder_1: decoder
    port map (
      Instr         => Instr,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      OPCODE        => OPCODE,
      w_e_regfile   => w_e_regfile,
      w_e_memory	=> w_e_memory,
      mask_sreg     => mask_sreg,
      state_sreg	=> state_sreg,
      rel_pc		=> rel_pc,
	  sel_im 		=> sel_im,
	  sel_ldi		=> sel_ldi,
      sel_alu		=> sel_alu,
      data_dcd		=> data_dcd);

  -- instance "Reg_File_1"
  Reg_File_1: Reg_File
    port map (
      clk           => clk,
      addr_opa      => addr_opa,
      addr_opb      => addr_opb,
      w_e_regfile   => w_e_regfile,
      data_opa      => data_opa,
      data_opb      => data_opb,
      data_ldi  	=> data_mux_ldi,
      addr_r3x		=> addr_r3x);
  
  -- instance "ALU_1"
  ALU_1: ALU
    port map (
      OPCODE 		=> OPCODE,
      OPA    		=> data_opa,
      OPB    		=> data_mux_im,
      RES 			=> data_alu,
      state_alu		=> state_alu);

  -- toplevel logic
      
	data_mux_im  <= data_dcd when (sel_im = '1') 	else data_opb; 
	data_mux_ldi <= data_dcd when (sel_ldi = '1') 	else data_mux_alu;  
	data_mux_alu <= data_alu when (sel_alu = '1') 	else data_mux_dm;  

	select_memory_output:process(	sel_memory, 
									data_pinb_o, 
									data_pinc_o, 
									data_pind_o, 
									data_portb_o, 
									data_portc_o, 
									data_segen_o, 
									data_seg0_o, 
									data_seg1_o, 
									data_seg2_o, 
									data_seg3_o, 
									data_dm)
	begin
		case sel_memory is
			when selcode_mem_pinb =>
				data_mux_dm <= data_pinb_o;
			when selcode_mem_pinc =>
				data_mux_dm <= data_pinc_o;
			when selcode_mem_pind =>
				data_mux_dm <= data_pind_o;
				
			when selcode_mem_portb =>
				data_mux_dm <= data_portb_o;
			when selcode_mem_portc =>
				data_mux_dm <= data_portc_o;
				
			when selcode_mem_segen =>
				data_mux_dm <= data_segen_o;
			when selcode_mem_seg0 =>
				data_mux_dm <= data_seg0_o;
			when selcode_mem_seg1 =>
				data_mux_dm <= data_seg1_o;				
			when selcode_mem_seg2 =>
				data_mux_dm <= data_seg2_o;
			when selcode_mem_seg3 =>
				data_mux_dm <= data_seg3_o;
				
			when others => 
				data_mux_dm <= data_dm;
		end case;
	end process;	
	
	hw_portb <= data_portb_o;
	hw_portc <= data_portc_o;
	reset <= hw_pind(0) and hw_pind(1) and hw_pind(2) and hw_pind(3) and hw_pind(4);
	hw_seg_enbl <= data_segen_o(3 downto 0);
	
	select_segment_register: process(	data_segen_o, 
										data_seg0_o,
										data_seg1_o,
										data_seg2_o,
										data_seg3_o)
	begin
		case data_segen_o(3 downto 0) is
			when "0001" =>
				hw_seg_cont <= data_seg0_o;
			when "0010" =>
				hw_seg_cont <= data_seg1_o;
			when "0100" =>
				hw_seg_cont <= data_seg2_o;
			when "1000" =>
				hw_seg_cont <= data_seg3_o;
			when others =>
				hw_seg_cont <= "00000000";
		end case;
	end process;


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
