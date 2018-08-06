library ieee;
use ieee.std_logic_1164.all;

entity verificador_senhas is
port(cs, clk, reset: in std_logic;
ch: in std_logic_vector (7 downto 0);
modo, abrir, bloq: out std_logic);
end entity;

architecture verificador_senhas of verificador_senhas is
type tipo_estado is (ES0, ES1, ES2, ES3, ES4);
signal estado: tipo_estado;
signal armazenar: std_logic_vector(7 downto 0);
begin
	muda_estado: process (clk, reset, cs)
	begin
		estado <= ES0;			-- indica o estado inicial
			case estado is
				when ES0 =>
					if cs='0' then estado <= ES1;		-- vai para o estado de configuracao
					else 				estado <= ES2;		-- vai para o estado de seguranca
					end if;
				when ES1 => 
					if clk='1' then
						armazenar<= ch;
						estado <= ES2;
					else
						estado <= ES1;
					end if;
				when ES2 =>
					if clk='1' then
						if armazenar=ch then
							estado <= ES3;
						else
							estado <= ES4;
						end if;
					else
						estado <= ES2;
					end if;
				when ES3 =>
					if reset='1' then estado <= ES2;
					else 					estado <= ES3;
					end if;
				when ES4 =>
					if reset='1' then estado <= ES1;
					else 					estado <= ES4;
					end if;
			end case;
	end process;
	
	with estado select 
		modo <= '1' when ES1,
				  '0' when others;
	with estado select 
		abrir <= '1' when ES2,
					'0' when others;
	with estado select 
		bloq <= '1' when ES4,
				  '0' when others;
end architecture;
				
					
	