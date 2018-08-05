
-- datapath for microprocessor
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity alu is   -------------------------------------------------- Unidade Logica Aritmetica(ULA)
  port (	input_alu		: 			in std_logic_vector(3 downto 0);
			--rst_ula      	:  		in STD_LOGIC;
         clk_alu      	:  		in STD_LOGIC;
			load_acc      	:  		in STD_LOGIC;
         imm      		:  		in std_logic_vector(3 downto 0);
			sel_alu			: 			in std_logic_vector(2 downto 0);
			dados_RF			: 			in std_LOGIC_VECTOR(3 downto 0); --Dados oriundos do Banco de registradores
			saida_aux_BCD  :        out std_logic_vector(3 downto 0);
         output_alu		: 			out STD_LOGIC_VECTOR (3 downto 0)
       );
end alu;

architecture bhv of alu is
component acc1 is	
  port ( input_acc 		: 			in STD_LOGIC_VECTOR (3 downto 0);
			--rst_acc   		: 			in STD_LOGIC;
         clk_acc   		: 			in STD_LOGIC;
         load   			: 			in STD_LOGIC;
         output_acc		: 			out STD_LOGIC_VECTOR (3 downto 0)
       );
end component;
component Aritmetica is
port(	in_A	: 	in std_logic_vector(3 downto 0);
		in_B	: 	in std_logic_vector(3 downto 0);
		aux	: 	in std_logic;
		outS	: 	out std_logic_vector(3 downto 0));
end component;

signal in_ACC, out_ACC, out_ALU: std_logic_vector(3 downto 0);
signal soma, subtr, and_logico, or_logico: std_logic_vector(3 downto 0);

begin
--saida_aux_BCD <= out_ALU;
saida_aux_BCD <= out_ACC;
ADD: Aritmetica port map(in_A=>out_ACC, in_B=>dados_RF, aux=>'0', outS=>soma);
SUB: Aritmetica port map(in_A=>out_ACC, in_B=>not(dados_RF), aux=>'1', outS=>subtr);
ACC: acc1 port map(input_acc=>in_ACC, clk_acc=>clk_alu, load=>load_acc, output_acc=>out_ACC); 
	process (clk_alu)
	begin
	  	--if(rst_ula = '0') then
			--out_ALU <= "0000";
		--if(clk_alu'event and clk_alu='1') then
		--if(clk_alu='0')then
			case (sel_alu) is ---- seleciona a OPERACAO a ser realizada pela ULA (o resultado vai para a saida da ULA)
				when "000" => ------------ SOMA 			(ADD Rd)
					out_ALU <= soma;
				when "011" => ------------ AND  			(ANDR Rd)
					out_ALU <= out_ACC AND dados_RF;	
				when "100" => ------------ OR   			(ORR Rd) 
					out_ALU <= out_ACC OR dados_RF;
				when "101" => ------------ NOT  			(INV)
					out_ALU <= NOT(out_ACC);
				when "110" => ------------ SUBTRACAO	(SUB Rd)
					out_ALU <= subtr;
				when others=> 
					out_ALU <= out_ACC; -- nenhuma operacao eh realizada (deixa passar direto)
			end case;					  -- a saida do ACC -> a saida da ULA
		
			case(sel_alu) is --MUX - responsavel por selecionar a ENTRADA do ACUMULADOR
				when "001" => --carrega constante no acumulador
					in_ACC <= imm; ------------------------------------------ (LOAD Imm)
				when "010" => --armazena saida da ULA no acumulador
					in_ACC <= out_ALU;
				when "111" => --carrega dados do RF para o acumulador
					in_ACC <= dados_RF; ------------------------------------- (MOVA Rd) -> Accumulator = Register[dd] 
				when others=> --SOMA, AND, OR, NOT, SUBTRACAO (os outros casos sao as demais operacoes)
					in_ACC <= out_ALU;
			end case;		
		--end if;
	end process;
	output_alu <= out_ALU;
	
end bhv;


library IEEE;
use IEEE.std_logic_1164.all;

entity acc1 is	-------------------------------------------------- Acumulador(ACC)
  port ( input_acc 		: 			in STD_LOGIC_VECTOR (3 downto 0);
			--rst_acc   		: 			in STD_LOGIC;
         clk_acc   		: 			in STD_LOGIC;
         load   			: 			in STD_LOGIC;
         output_acc		: 			out STD_LOGIC_VECTOR (3 downto 0)
       );
end acc1;

architecture bhv of acc1 is
signal temp : STD_LOGIC_VECTOR(3 downto 0);
begin
	process (input_acc, load, clk_acc)
	begin
		--if (rst_acc = '0') then
			--output_acc <= "0000";
		if (clk_acc'event and clk_acc = '1') then
		--if(clk_acc='0')then
				if (load = '1') then -- Esse load 
					output_acc <= input_acc;
					temp <= input_acc;
				else
					output_acc <= temp;
				end if;
		end if;
	end process;
end bhv;



library IEEE;
use IEEE.std_logic_1164.all;

entity rf is --------------------- Banco de Registradores(RF)
  port ( input_rf  		: 			in std_logic_vector(3 downto 0); -- entrada de dados do banco reg
			--rst_rf    		: 			in STD_LOGIC;
         clk_rf    		: 			in STD_LOGIC;
         sel_rf    		: 			in std_logic_vector(1 downto 0); -- seleciona qual registrador vai utilizar
         rd_wr    		: 			in std_logic; 							-- leitura ou escrita
         output_rf 		: 			out std_logic_vector(3 downto 0)); 		
end rf;

architecture bhv of rf is
signal out0, out1, out2, out3 : std_logic_vector(3 downto 0):="0000";
begin

	process (clk_rf)
	begin
	  --if(rst_rf = '0')then
			--output_rf <= "0000";
	  if(clk_rf'event and clk_rf='1')then
	  --if(clk_rf='0')then
			if(rd_wr = '0') then 	----------------- ESCREVER
				case (sel_rf) is ------- seleciona em qual registrador vai armazenar(escrever) a entrada
					when "00" => 
						out0 <= input_rf; --escrevendo em RF[0]
					when "01" => 
						out1 <= input_rf; --escrevendo em RF[1]
					when "10" => 
						out2 <= input_rf; --escrevendo em RF[2]
					when "11" =>
						out3 <= input_rf; --escrevendo em RF[3]
					when others =>
				end case;
			else					------------------------ LER
				case (sel_rf) is ------- seleciona qual registrador vai ter os dados colocados na saida do banco (dados lidos)
					when "00" =>
						output_rf <= out0; --lendo de RF[0]
					when "01" =>
						output_rf <= out1; --lendo de RF[1]
					when "10" =>
						output_rf <= out2; --lendo de RF[2]
					when "11" =>
						output_rf <= out3; --lendo de RF[3]
					when others =>
				end case;
			end if;
	  end if;
	end process;	
end bhv;

library IEEE;
use IEEE.std_logic_1164.all;

entity BlocoOperacional is
  port ( loadACC, rd_wr_DP, clk_DP     			      : 			in STD_LOGIC; 							--reset, load do acumulador, ler/escrever no RF (banco reg), clock do DP
         in_IMM							 						: 			in std_LOGIC_VECTOR(3 downto 0); --constante
			selRF							 							: 			in std_LOGIC_VECTOR(1 downto 0); --seleciona os RF do banco de registradores 
			selALU						 							: 			in std_LOGIC_VECTOR(2 downto 0); --seleciona operacoes da ALU
			saida_aux_DP_BCD										:        out std_logic_vector(3 downto 0);
			output_DP												: 			out STD_LOGIC_VECTOR (3 downto 0)); --saida do datapath
      
end BlocoOperacional;

architecture rtl2 of BlocoOperacional is

component alu is   -----------------------
  port (	input_alu		: 			in std_logic_vector(3 downto 0);
			--rst_ula      	:  		in STD_LOGIC;
         clk_alu      	:  		in STD_LOGIC;
			load_acc      	:  		in STD_LOGIC;
         imm      		:  		in std_logic_vector(3 downto 0);
			sel_alu			: 			in std_logic_vector(2 downto 0);
			dados_RF			: 			in std_LOGIC_VECTOR(3 downto 0);
			saida_aux_BCD	:        out std_logic_vector(3 downto 0);
         output_alu		: 			out STD_LOGIC_VECTOR (3 downto 0)
       );
end component;

component acc is	------------------
  port ( input_acc 		: 			in STD_LOGIC_VECTOR (3 downto 0);
			--rst_acc   		: 			in STD_LOGIC;
         clk_acc   		: 			in STD_LOGIC;
         load   			: 			in STD_LOGIC;
         output_acc		: 			out STD_LOGIC_VECTOR (3 downto 0)
       );
end component;

component rf is ---------------------
  port ( input_rf  		: 			in std_logic_vector(3 downto 0); 
			--rst_rf    		: 			in STD_LOGIC;
         clk_rf    		: 			in STD_LOGIC;
         sel_rf    		: 			in std_logic_vector(1 downto 0); 
         rd_wr    		: 			in std_logic; 
         output_rf 		: 			out std_logic_vector(3 downto 0)
			); 	
end component;

signal saida_ULA, saida_RF: std_LOGIC_VECTOR(3 downto 0);
begin
ula: alu port map (input_alu=>saida_ULA, clk_alu=>clk_DP, load_acc=>loadACC, imm=>in_IMM, sel_alu=>selALU, dados_RF=>saida_RF, saida_aux_BCD=>saida_aux_DP_BCD, output_alu=>saida_ULA);
banco_reg: rf port map (input_rf=>saida_ULA, clk_rf=>clk_DP, sel_rf=>selRF, rd_wr=>rd_wr_DP, output_rf=>saida_RF);
		
output_DP <= saida_ULA;

end rtl2;