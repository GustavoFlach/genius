library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Timer is
	GENERIC(
		Freq: integer
		);
	PORT(rst: in STD_LOGIC;
		  clk: in STD_LOGIC;
		  output_timer: out integer
		);
		  
end Timer;

architecture Behavioral of Timer is

begin

	process(clk, rst)
	
	--variable : integer range 0 to Dmax := 0;
	
		variable count_clk: integer range 0 to Freq := 0;
		
		begin
		if(rst = '1') then
			count_clk := 0;
		elsif(clk'event and clk = '1') then
			
				if(count_clk < Freq) then
					count_clk := count_clk + 1;
					output_timer <= count_clk;
				else
					count_clk := 0;
				end if;
	
		else
			count_clk := count_clk;
		end if;
	
	--output_timer <= count_clk;
	end process;

end Behavioral;