library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_datamem.all;


entity io_reg is
  port(clk   	: in std_logic;
       reset 	: in std_logic;
	   w_e 		: in  std_logic;
       data_in  : in  std_logic_vector(7 downto 0);
       data_out : out std_logic_vector (7 downto 0));
end io_reg;


architecture Behavioral of io_reg is
  signal data : std_logic_vector (7 downto 0) := "00000000";
begin
  
  write_data : process(clk, data_in)
  begin
    
    if clk'event and clk = '1' then
      if reset = '1' then
        data <= "00000000";
      elsif w_e = '1' then
        data <= data_in;        
      end if;
    end if;
  end process write_data;

  data_out <= data;

end Behavioral;



