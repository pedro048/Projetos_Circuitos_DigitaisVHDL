library ieee;
use ieee.std_logic_1164.all;

entity Aritmetica is
port(	in_A	: 	in std_logic_vector(3 downto 0);
		in_B	: 	in std_logic_vector(3 downto 0);
		aux	: 	in std_logic;
		outS	: 	out std_logic_vector(3 downto 0));
end Aritmetica;

architecture Aritmetica of Aritmetica is
component Adder is
port(	A, B			: 		in std_logic;
		aux_adder	: 		in std_logic ;
		saida_aux	: 		out std_logic;
		saida			: 		out std_logic);
end component;

signal aux_0, aux_1, aux_2, aux_3: std_logic;
signal s0,s1,s2,s3: std_logic;

begin
adde0: Adder port map(in_A(0), in_B(0), aux, aux_0, s0);
adde1: Adder port map(in_A(1), in_B(1), aux_0, aux_1, s1);
adde2: Adder port map(in_A(2), in_B(2), aux_1, aux_2, s2);
adde3: Adder port map(in_A(3), in_B(3), aux_2, aux_3, s3);

outS(0) <= s0;
outS(1) <= s1;
outS(2) <= s2;
outS(3) <= s3;
end architecture;