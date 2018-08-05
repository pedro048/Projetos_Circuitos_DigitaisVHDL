library ieee;
use ieee.std_logic_1164.all;

entity Adder is
port(	A, B			: 		in std_logic;
		aux_adder	: 		in std_logic ;
		saida_aux	: 		out std_logic;
		saida			: 		out std_logic);
end Adder;

architecture Adder of Adder is
begin
saida_aux <= (A and B) or (aux_adder and (A xor B));
saida <= A xor B xor aux_adder;

end Adder;