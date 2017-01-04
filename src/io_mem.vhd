library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;



entity io_mem is
  port(	   clk      	: in STD_LOGIC;
		   reset		: in STD_LOGIC;           
           data_in		: in STD_LOGIC_VECTOR (7 downto 0);
           addr			: in STD_LOGIC_VECTOR (9 downto 0);           
           w_e      	: in bit;
           dsbl     	: in bit;
           
           data_pinb 	: in STD_LOGIC_VECTOR (7 downto 0);
           data_pinc 	: in STD_LOGIC_VECTOR (7 downto 0);
           data_pind 	: in STD_LOGIC_VECTOR (4 downto 0);
           
           data_portb 	: out STD_LOGIC_VECTOR (7 downto 0);
           data_portc 	: out STD_LOGIC_VECTOR (7 downto 0);
           
           data_segen 	: out STD_LOGIC_VECTOR (7 downto 0);
           data_segcont : out STD_LOGIC_VECTOR (7 downto 0);
           
           data_out 	: out STD_LOGIC_VECTOR (7 downto 0));
end io_mem;


architecture Behavioral of io_mem is
	signal 	pinb : std_logic_vector (7 downto 0) := (others => '0');
	signal 	pinc : std_logic_vector (7 downto 0) := (others => '0');
	signal 	pind : std_logic_vector (7 downto 0) := (others => '0');
	
	signal	portb : std_logic_vector (7 downto 0) := (others => '0');
	signal	portc : std_logic_vector (7 downto 0) := (others => '0');
	
	signal	segen : std_logic_vector (7 downto 0) := (others => '0');
	signal	seg0 : std_logic_vector (7 downto 0) := (others => '0');
	signal	seg1 : std_logic_vector (7 downto 0) := (others => '0');
	signal	seg2 : std_logic_vector (7 downto 0) := (others => '0');
	signal	seg3 : std_logic_vector (7 downto 0) := (others => '0');
	
	signal	data : std_logic_vector (7 downto 0) := (others => '0');
begin
  
	update_data: process (clk)
	begin
	  if clk'event and clk = '1' then 
		if dsbl = '0' then
			
			pinb <= data_pinb;
			pinc <= data_pinc;
			pind <= "000"&data_pind;
			
			if w_e = '1' then
				if addr(3 downto 0) = "0011" then portb <= data_in;
				elsif addr(3 downto 0) = "0100" then portc <= data_in;
				elsif addr(3 downto 0) = "0101" then segen <= data_in;
				elsif addr(3 downto 0) = "0110" then seg0 <= data_in;
				elsif addr(3 downto 0) = "0111" then seg1 <= data_in;
				elsif addr(3 downto 0) = "1000" then seg2 <= data_in;
				elsif addr(3 downto 0) = "1001" then seg3 <= data_in;
				end if;
			else
				case addr(3 downto 0) is 
					when "0000" => data <= pinb;
					when "0001" => data <= pinc;
					when "0010" => data <= pind;
					when "0011" => data <= portb;
					when "0100" => data <= portc;
					when "0101" => data <= segen;
					when "0110" => data <= seg0;
					when "0111" => data <= seg1;
					when "1000" => data <= seg2;
					when "1001" => data <= seg3;				
					when others => null;
				end case;
			end if;		
		end if;
	  end if;
	end process;
	
	
	update_segcont:process(segen, seg0, seg1, seg2, seg3)
	begin
		case segen(3 downto 0) is
			when "0001" => data_segcont <= seg0;
			when "0010" => data_segcont <= seg1;
			when "0100" => data_segcont <= seg2;
			when "1000" => data_segcont <= seg3;
			when others => data_segcont <= (others => '0');
		end case;
	end process;
	
	
	data_portb <= portb;
    data_portc <= portc;
    data_segen <= segen;
    data_out <= data;
	
end Behavioral;



