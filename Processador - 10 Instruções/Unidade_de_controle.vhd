-- controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity Unidade_de_controle is
   port ( rst                       : 				in std_logic;
			 start, clkCTRL				: 				in STD_LOGIC;
			 enb,loadACC					:				out std_logic;
          imm   							: 				out std_logic_vector(3 downto 0);
			 selALU   						: 				out std_logic_vector (2 downto 0);
			 selRF							: 				out std_logic_vector(1 downto 0);
			 hex0, hex1, hex2, hex3		: 				out std_logic_vector(6 downto 0)
       );
end Unidade_de_controle;

architecture fsm of Unidade_de_controle is
  type state_type is (s0,s1,s2,s3,s4,s5,s6,done);
  signal state : state_type; 		
	
	-- constantes declaradas para facilitar o código de leitura
	
	constant mova    : std_logic_vector(3 downto 0) := "0000";
	constant movr    : std_logic_vector(3 downto 0) := "0001";
	constant load    : std_logic_vector(3 downto 0) := "0010";
	constant add	  : std_logic_vector(3 downto 0) := "0011";
	constant sub	  : std_logic_vector(3 downto 0) := "0100";
	constant andr    : std_logic_vector(3 downto 0) := "0101";
	constant orr     : std_logic_vector(3 downto 0) := "0110";
	constant jmp	  : std_logic_vector(3 downto 0) := "0111";
	constant inv     : std_logic_vector(3 downto 0) := "1000";
	constant halt	  : std_logic_vector(3 downto 0) := "1001";

-- À medida que você adiciona mais código para seus algoritmos, certifique-se de aumentar o
-- tamanho do array. ie. 2 linhas de código aqui, significa tamanho de array de 0 a 1.
	type PM_BLOCK is array (0 to 7) of std_logic_vector(7 downto 0); ---------------------- Memoria de Instrucao
	constant PM : PM_BLOCK := (
	 -- Conjunto de INSTRUCOES (Programa)
	
		"00101010",
		"01110011",
		"00011100",
		"00100011",
		"00010000",
		"00100101",
		"00110000",
		"10011111"	 -- halt												 -> Stop execution
    );
	
begin
	process (clkCTRL)
		variable IR 			: 		std_logic_vector(7 downto 0); -- Registrador de Instrução(IR)
		variable OPCODE 		: 		std_logic_vector(3 downto 0); -- Codigo para indicar a operacao(OPCODE)
		variable ADDRESS 		: 		std_logic_vector(3 downto 0); -- Pode representar a constante, o indice do registrador, e o endereco do jump 
		variable PC 			: 		integer;								-- Contador de Programa(PC)
		variable jump        :		std_logic_vector(3 downto 0); -- Variavel para o jump
	begin
		if(rst='0')then
			state <= s0;
		elsif(clkCTRL'event and clkCTRL='1') then
      --if(clkCTRL='0')then		
			case state is
				when s0 =>   -----------------INICIO
					PC := 0;  -- Inicialmente zera o contador de programa(PC)
					imm <= "0000"; -- A constante inicialmente fica com valor zero
					if(start = '1')then -- Analisa o botao(start) para iniciar o processamento 
						state <= s1; -- Vai para o estado de BUSCA
					else 
						state <= s0; -- Fica na preparacao antes de comecar o processamento
					end if;
				when s1 =>	 -----------------BUSCA
					IR := PM(PC); -- O IR recebe a instrucao armazenada na posicao PC da memoria de instrucao(PM)
					OPCODE := IR(7 downto 4); -- Indentificador da operacao(os 4 bits menos significativos)
					ADDRESS:= IR(3 downto 0); -- Pode ser o valor da constante, indice do registrador, endereco do jump(os 4 bits mais significativos) 
					state <= s2; -- vai para o estado de incrementar o contador de programa(PC)
				when s2 =>				--incrementa o PC
					PC := PC + 1;
					state <= s3; -- vai para o estado de decodificacao
				when s3 =>	 ----------------DECODIFICAÇÃO
					case OPCODE IS  -- escolhe a operacao a ser processada
						when load =>      --carrega constante no acumulador
							selALU <= "001"; -- faz com que o seletor da ULA acione : accumulator <= constante 
							imm <= ADDRESS;  -- o valor da constante vem da variavel ADDRESS, que eh os 4 bits mais significativos do IR
							enb <= '1'; -----ler (faz leitura no banco de registradores) 
							loadACC <= '1'; -- aciona o acumulador
							state <= s4;
							hex0 <= "1000010"; --d
							hex1 <= "0001000"; --a
							hex2 <= "0000001"; --o
							hex3 <= "1110001"; --L
						when add =>  -- realiza uma SOMA     
							selALU <="000";   -- faz com que o seletor da ULA acione : accumulator <= acumulador+RF[dd]
							selRF <= ADDRESS(3 downto 2); -- indica qual registrador vai ser usado
							enb <= '1';--ler
							loadACC<='0';
							--loadACC<='1';
							state <= s5; -- aciona o acumulador
							hex0 <= "1111111";
							hex1 <= "1000010"; --d
							hex2 <= "1000010"; --d
							hex3 <= "0001000"; --A
						when movr => --Armazena a valor do acumulador no RF
							selALU <="010"; -- faz com que o seletor da ULA acione : registrador[dd] <= acumulador
							loadACC <= '0'; -- nao aciona o acumulador
							enb <= '0'; --escrever(escreve no banco de registradores)
							selRF <= ADDRESS(3 downto 2); -- indica qual registrador vai ser usado
							state <= s4; 
							hex0 <= "1111111";
							hex1 <= "0001000"; --A
							hex2 <= "1110110"; --=
							hex3 <= "0111000"; --F
						when andr => -- AND logico
							selALU <= "011"; -- faz com que o seletor da ULA acione : acumulador <= acumulador AND registrador[dd]
							selRF <= ADDRESS(3 downto 2); -- indica qual registrador vai ser usado
							enb <= '1'; --ler(faz a leitura do banco de registradores)
							loadACC <= '1'; -- aciona o acumulador
							state <= s4;
							hex0 <= "1111111";
							hex1 <= "1000010"; --d 
							hex2 <= "1101010"; --n
							hex3 <= "0001000"; --a
						when orr => -- OR logico
							selALU <= "100"; -- faz com que o seletor da ULA acione : acumulador <= acumulador OR registrador[dd]
							selRF <= ADDRESS(3 downto 2); -- indica qual registrador vai ser usado
							enb <= '1'; --ler(faz a leitura do banco de registradores)
							loadACC <= '1'; -- aciona o acumulador
							state <=s4;
							hex0 <= "1111111";
							hex1 <= "1111111"; 
							hex2 <= "1000001"; --u
							hex3 <= "0000001"; --O
						when inv => -- Inversor
							selALU <= "101"; -- faz com que o seletor da ULA acione : acumulador <= not(acumulador) 
							enb <= '1'; --ler(faz a leitura do banco de registradores)
							loadACC <= '1'; -- aciona acumulador
							state <= s4;
							hex0 <= "1111111";
							hex1 <= "0000001"; --o
							hex2 <= "0001000"; --a
							hex3 <= "1101010"; --N
						when sub => -- realiza uma SUBTRACAO
							selALU <="110"; -- faz com que o seletor da ULA acione : accumulator <= acumulador - RF[dd]
							selRF <= ADDRESS(3 downto 2); -- indica qual registrador vai ser usado
							enb <= '1';--ler(faz a leitura do banco de registradores)
							loadACC<='0';
							--loadACC<='1';
							state <= s5;
							hex0 <= "1111111";
							hex1 <= "1100000"; --b
							hex2 <= "1000001"; --u
							hex3 <= "0100100"; --S
						when mova => --carregar do RF para ACC
							selALU <= "111"; -- faz com que o seletor da ULA acione : accumulator <= registrador[dd]
							enb <= '1'; --ler(faz a leitura do banco de registradores)
							--loadACC<='1';
							selRF <= ADDRESS(3 downto 2);-- o primeiro clock atualiza a saida do RF
							state <= s5;
							hex0 <= "1111111";
							hex1 <= "0111000"; --F
							hex2 <= "1110110"; --=
							hex3 <= "0001000"; --A
						when jmp => -- Faz o jump nas instrucoes 
							jump := ADDRESS(3 downto 0);
							case jump is
								when "0000" =>
									PC := 0;
									state <= s1;
								when "0001" =>
									PC := 1;
									state <= s1;
								when "0010" =>
									PC := 2;
									state <= s1;
								when "0011" =>
									PC := 3;
									state <= s1;
								when "0100" =>
									PC := 4;
									state <= s1;
								when "0101" =>
									PC := 5;
									state <= s1;
								when "0110" =>
									PC := 6;
									state <= s1;
								when "0111" =>
									PC := 7;
									state <= s1;
								when "1000" =>
									PC := 8;
									state <= s1;
								when "1001" =>
									PC := 9;
									state <= s1;
								when "1010" =>
									PC := 10;
									state <= s1;
								when "1011" =>
									PC := 11;
									state <= s1;
								when "1100" =>
									PC := 12;
									state <= s1;
								when "1101" =>
									PC := 13;
									state <= s1;
								when "1110" =>
									PC := 14;
									state <= s1;
								when "1111" =>
									PC := 15;
									state <= s1;
								when others =>
							end case;
						when halt =>      --para a execução
							hex0 <= "1111111";
							hex1 <= "1000010"; --d
							hex2 <= "1101010"; --n
							hex3 <= "0110000"; --e
							state <= done; -- estado para encerrar o processamento
						when others =>  --CASO CONTRÁRIO
						state <= s1; -- volta para o estado de busca
					end case;
				when s4 => -- tudo é zerado
					loadACC <= '0';
					enb <='1'; --ler
					state <= s1; -- volta para o estado de busca
				when s5 => --esse estado é ativado quando a instrução precisa usar o RF
					loadACC <='1'; -- o segundo clk atualiza o ACC
					state <= s4;
				when done =>  
					state <= done;
				when others =>
			end case;
		end if;
	end process;				
end fsm;