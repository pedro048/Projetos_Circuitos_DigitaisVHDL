
-----------------------------------------
--Autor: Pedro Victor Andrade Alves
--Projeto: Processador de 10 instrucoes
--Matricula: 2015095775
--Disciplina: Circuitos Digitais/DCA0202
-----------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity Processador is
   port ( start         							: 				in STD_LOGIC;
          clk           							: 				in STD_LOGIC;							 -- clk manual
			 rst           							: 				in STD_LOGIC;
          hex0, hex1, hex2, hex3					: 				out std_logic_vector(6 downto 0); -- Displays para mostrar qual eh a operacao 
			 hex4, hex5									: 				out std_logic_vector(6 downto 0);  -- Displays para mostrar o resultado do operacao
			 outputBCD									:   			out std_logic_vector(3 downto 0);
			 outputCPU									:   			out std_logic_vector(3 downto 0)
			 );
end Processador;

architecture struc of Processador is
component Unidade_de_controle is
   port ( rst 								: 				in std_logic;
			 start, clkCTRL				: 				in STD_LOGIC;
			 enb,loadACC					:				out std_logic;
          imm   							: 				out std_logic_vector(3 downto 0);
			 selALU   						: 				out std_logic_vector (2 downto 0);
			 selRF							: 				out std_logic_vector(1 downto 0);
			 hex0, hex1, hex2, hex3		: 				out std_logic_vector(6 downto 0)
       );
end component;

component BlocoOperacional is
  port ( loadACC, rd_wr_DP, clk_DP     			      : 			in STD_LOGIC; 
         in_IMM							 						: 			in std_LOGIC_VECTOR(3 downto 0);
			selRF							 							: 			in std_LOGIC_VECTOR(1 downto 0); 
			selALU						 							: 			in std_LOGIC_VECTOR(2 downto 0);
			saida_aux_DP_BCD										:        out std_logic_vector(3 downto 0);
			output_DP												: 			out STD_LOGIC_VECTOR (3 downto 0)); 
end component;

component divFreq is
port(clk_in: in std_logic;
	clk_out: out std_logic);
end component;

signal immediate 						: std_logic_vector(3 downto 0);
signal selRF							: std_logic_vector(1 downto 0);
signal loadACC, enb					: std_logic;
signal selALU							: std_logic_vector(2 downto 0);
signal saidaCPU						: std_logic_vector(3 downto 0);
signal saidaBCD						: std_logic_vector(3 downto 0);
signal hex0S, hex1S, hex2S, hex3S: std_logic_vector(6 downto 0);
signal estado_freq					: std_logic;

begin
freq: divFreq port map (clk, estado_freq);
controle: Unidade_de_controle port map(rst=>rst, start=>start, clkCTRL=>estado_freq, enb=>enb, loadACC=>loadACC, imm=>immediate, selALU=>selALU, selRF=>selRF, hex0=>hex0S, hex1=>hex1S, hex2=>hex2S, hex3=>hex3S); 
operacional: BlocoOperacional port map(loadACC=>loadACC, rd_wr_DP=>enb, clk_DP=>estado_freq, in_IMM=>immediate, selRF=>selRF, selALU=>selALU, saida_aux_DP_BCD=>saidaBCD, output_DP=>saidaCPU); 

hex0 <= hex0S;
hex1 <= hex1S;
hex2 <= hex2S;
hex3 <= hex3S;
 
  process(estado_freq, saidaCPU)
  begin
		if(estado_freq'event and estado_freq='1') then
			outputCPU<=saidaCPU;
			outputBCD<=saidaBCD;
			case (saidaBCD) is 					-- Resultados das operacoes processadas
				when "0001" => 		-- 1		
					hex5 <= "0000001";
					hex4 <= "1001111";
				when "0010" => 		-- 2
					hex5 <= "0000001";
					hex4 <= "0010010";
				when "0011" => 		-- 3
					hex5 <= "0000001";
					hex4 <= "0000110";
				when "0100" => 		-- 4
					hex5 <= "0000001";
					hex4 <= "1001100";
				when "0101" => 		-- 5
					hex5 <= "0000001";
					hex4 <= "0100100";
				when "0110" => 		-- 6
					hex5 <= "0000001";
					hex4 <= "0100000";
				when "0111" => 		-- 7
					hex5 <= "0000001";
					hex4 <= "0001111";	
				when "1000" => 		-- 8
					hex5 <= "0000001";
					hex4 <= "0000000";
				when "1001" => 		-- 9
					hex5 <= "0000001";
					hex4 <= "0000100";
				when "1010" => 		-- 10
					hex5 <= "1001111";
					hex4 <= "0000001";
				when "1011" => 		-- 11
					hex5 <= "1001111";
					hex4 <= "1001111";
				when "1100" => 		-- 12
					hex5 <= "1001111";
					hex4 <= "0010010";
				when "1101" => 		-- 13
					hex5 <= "1001111";
					hex4 <= "0000110"; 
				when "1110" => 		-- 14
					hex5 <= "1001111";
					hex4 <= "1001100"; 
				when "1111" => 		-- 15
					hex5 <= "1001111";
					hex4 <= "0100100"; 
			  when others =>
			end case;
	   end if;
  end process;							
end struc;



