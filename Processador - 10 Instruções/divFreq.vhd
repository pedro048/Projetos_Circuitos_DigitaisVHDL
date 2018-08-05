library ieee;
use ieee.std_logic_1164.all;

entity divFreq is
port(clk_in: in std_logic;
clk_out: out std_logic);
end entity;

architecture div of divFreq is
signal cont: integer :=1;
signal estado: std_logic;
begin
	process(clk_in,cont)
	begin
		if(clk_in='1' and clk_in'event) then
			if cont=25000000 then
				estado <= not estado;
				cont <= 1;
			else
				cont <= cont+1;
			end if;
		end if;
	end process;
	clk_out <= estado;
end architecture;