library ieee;
use ieee.std_logic_1164.all;

-----------------------------------
--Autor: Pedro Victor Andrade Alves
--Matricula: 2015095775
--Disciplina: Circuitos Digitais/DCA0202
-----------------------------------

entity contador0para9 is
port(clk, mode, config, str, set, reset: in std_logic;
alarme: out std_logic_vector(3 downto 0);
hora, minuto: out std_logic;
bar7, bar8, bar1, bar2, bar3, bar4, bar5, bar6: out std_logic_vector(6 downto 0));
end entity;

architecture contador of contador0para9 is
------------------------------
component divFreq is
port(clk_in: in std_logic;
clk_out: out std_logic);
end component;

signal cont1: integer:=0; -- Contadores para os segundos, minutos e horas do relogio
signal cont2: integer:=0;
signal cont3: integer:=0;
signal cont4: integer:=0;
signal cont5: integer:=0;
signal cont6: integer:=0;
----------------------------
signal cont3_1: integer:=0; -- Contadores para os minutos e horas do alarme
signal cont4_1: integer:=0;
signal cont5_1: integer:=0;
signal cont6_1: integer:=0;
----------------------------
signal cont1_2: integer:=0; -- Contadores para os segundos, minutos e horas do cronometro
signal cont2_2: integer:=0;
signal cont3_2: integer:=0;
signal cont4_2: integer:=0;
signal cont5_2: integer:=0;
signal cont6_2: integer:=0;
---------------------------------
signal estado_freq: std_logic;
signal aux: std_logic:='0';
signal aux1: std_logic:='0';
signal aux2: std_logic:='0';
signal aux_estado6: integer; -- Sao usados na comparacao para o alarme 
signal aux_estado5: integer;
signal aux_estado4: integer;
signal aux_estado3: integer;
------------------------------
signal BCD1_bar: std_logic_vector(6 downto 0); -- Usado no momento de mostrar o relogio
signal BCD2_bar: std_logic_vector(6 downto 0);
signal BCD3_bar: std_logic_vector(6 downto 0);
signal BCD4_bar: std_logic_vector(6 downto 0);
signal BCD5_bar: std_logic_vector(6 downto 0);
signal BCD6_bar: std_logic_vector(6 downto 0);
-----------------------------------
signal BCD3_1_bar: std_logic_vector(6 downto 0); -- Usado no momento de mostrar o alarme
signal BCD4_1_bar: std_logic_vector(6 downto 0);
signal BCD5_1_bar: std_logic_vector(6 downto 0);
signal BCD6_1_bar: std_logic_vector(6 downto 0);
------------------------------------
signal BCD1_2_bar: std_logic_vector(6 downto 0); -- Usado no momento de mostrar o cronometro
signal BCD2_2_bar: std_logic_vector(6 downto 0);
signal BCD3_2_bar: std_logic_vector(6 downto 0);
signal BCD4_2_bar: std_logic_vector(6 downto 0);
signal BCD5_2_bar: std_logic_vector(6 downto 0);
signal BCD6_2_bar: std_logic_vector(6 downto 0);
-------------------------------------
signal cont_mode: integer:=0;
signal cont: integer:=1;
signal parar: std_logic:='0';
signal cont_cron: std_logic:='0';
signal cont_temp: integer:=0;
signal cronometro: std_logic:='0';

begin

freq: divFreq port map (clk, estado_freq);
	process(estado_freq) 
	begin
		if(estado_freq='1' and estado_freq'event) then
			-------------------------------------------------- Contagem do relogio
			if(cont1=10) then
				cont1 <= 0;
				cont2 <= cont2+1;
			else
				cont1 <= cont1+1;
			end if;
			if(cont2=6) then
				cont2 <= 0;
				cont3 <= cont3+1;
			end if;
			if(cont3=10) then
				cont3 <= 0;
				cont4 <= cont4+1;
			end if;
			if(cont4=6) then
				cont4 <= 0;
				cont5 <= cont5+1;
			end if;
			if(cont5=10) then
				cont5 <= 0;
				cont6 <= cont6+1;
			end if;
			if(cont6=2 and cont5=4) then 
				cont5 <= 0;
				aux <= '1';
			end if;
			if(cont6=2 and aux='1') then
				cont6 <= 0;
				aux <= '0';
			end if;
			-------------------------------------------------- Contagem do alarme
			if(cont3_1=10) then
				cont3_1 <= 0;
				cont4_1 <= cont4_1+1;
			end if;
			if(cont5_1=10) then
				cont5_1 <= 0;
				cont6_1 <= cont6_1+1;
			end if;
			if(cont6_1=2 and cont5_1=4) then 
				cont5_1 <= 0;
				aux1 <= '1';
			end if;
			if(cont6_1=2 and aux1='1') then
				cont6_1 <= 0;
				aux1 <= '0';
			end if;
			-------------------------------------------------- Contagem do cronometro
			if(cronometro='1')then
				if(cont1_2=10) then
					cont1_2 <= 0;
					cont2_2 <= cont2_2+1;
				else
					cont1_2 <= cont1_2+1;
				end if;
				if(cont2_2=6) then
					cont2_2 <= 0;
					cont3_2 <= cont3_2+1;
				end if;
				if(cont3_2=10) then
					cont3_2 <= 0;
					cont4_2 <= cont4_2+1;
				end if;
				if(cont4_2=6) then
					cont4_2 <= 0;
					cont5_2 <= cont5_2+1;
				end if;
				if(cont5_2=10) then
					cont5_2 <= 0;
					cont6_2 <= cont6_2+1;
				end if;
				if(cont6_2=2 and cont5_2=4) then 
					cont5_2 <= 0;
					aux2 <= '1';
				end if;
				if(cont6_2=2 and aux2='1') then
					cont6_2 <= 0;
					aux2 <= '0';
				end if;
			end if;	
			-------------------------------------------------- Modos de operacao (relogio, alarme, cronometro)
			if(mode='0' and cont_mode=0) then
				cont_mode <= 1; 						-- Ao pressionar mode vai para alarme
			end if;
			if(mode='0' and cont_mode=1) then
				cont_mode <= 2; 						-- Ao pressionar mode novamente vai para cronometro
			end if;
			if(mode='0' and cont_mode=2) then
				cont_mode <= 0;						-- Pressionando mode uma terceira vez, volta para relogio
			end if;
			
											
			if(cont_mode=0)then ------------- executa o RELOGIO
				bar7 <= "1111111";
			   bar8 <= "1111111";
		      ------------------		
				bar1 <= BCD1_bar;
				bar2 <= BCD2_bar; -- segundos
				------------------
				bar3 <= BCD3_bar;
				bar4 <= BCD4_bar; -- minutos 
				------------------
				bar5 <= BCD5_bar;
				bar6 <= BCD6_bar; -- horas
				------------------
				if(config='0') then
					cont <= 1;
				else
					if(cont=1) then --- incrementar as horas
						hora <= '1';
						minuto <= '0';
						if(str='0') then
							cont5 <= cont5+1;
						end if;
					end if;
					if(set='0' and cont=1) then
						cont <= 2;
					end if;
					if(cont=2) then --- incrementar os minutos
						hora <= '0';
						minuto <= '1';
						if(str='0') then
							cont3 <= cont3+1;
						end if;
					end if;
					if(set='0' and cont=2) then
						cont <= 3;
						hora <= '0';
						minuto <= '0';
					end if;
										
					if(reset='0') then --- reiniciar o relogio
						cont1 <= 0;
						cont2 <= 0;
						cont3 <= 0;
						cont4 <= 0;
						cont5 <= 0;
						cont6 <= 0;
					end if;
				end if;
			end if;
										
			if(cont_mode=1)then ------------- executa o ALARME
				bar7 <= "1111111";
			   bar8 <= "1111111";
				------------------
				bar1 <= "1111111";	
				bar2 <= "1111111";	--- segundos 
				-------------------
				bar3 <= BCD3_1_bar;
				bar4 <= BCD4_1_bar;	--- minutos 
				-------------------
				bar5 <= BCD5_1_bar;
				bar6 <= BCD6_1_bar;	--- horas 
				-------------------
				if(config='0') then
					cont <= 1;
				else
					if(cont=1) then --- seleciona a hora
						hora <= '1';
						minuto <= '0';
						if(str='0') then
							cont5_1 <= cont5_1+1;
						end if;
						aux_estado6 <= cont6_1;
						aux_estado5 <= cont5_1;
					end if;
					if(set='0' and cont=1) then
						cont <= 2;
					end if;
					if(cont=2) then --- seleciona os minutos
						hora <= '0';
						minuto <= '1';
						if(str='0') then
							cont3_1 <= cont3_1+1;
						end if;
					   aux_estado4 <= cont4_1;
						aux_estado3 <= cont3_1;
					end if;
					if(set='0' and cont=2) then
						cont <= 3;
						hora <= '0';
						minuto <= '0';
					end if;
										
					if(reset='0') then --- limpa o horario do alarme
						aux_estado6 <= 0;
						aux_estado5 <= 0;
						aux_estado4 <= 0;
						aux_estado3 <= 0;
						cont3_1 <= 0;
						cont4_1 <= 0;
						cont5_1 <= 0;
						cont6_1 <= 0;
					end if;
			   end if;
		   end if;	
			if(cont_mode=2) then ------------- executa o CRONOMETRO
				bar1 <= BCD1_2_bar;
				bar2 <= BCD2_2_bar; -- segundos 
				------------------
				bar3 <= BCD3_2_bar;
				bar4 <= BCD4_2_bar; -- minutos  
				------------------
				bar5 <= BCD5_2_bar;
				bar6 <= BCD6_2_bar; -- horas 
				------------------
				if(cont_cron='0') then --- O cronometro inicia zerado
					bar1 <= "0000001";
					bar2 <= "0000001";
					bar3 <= "0000001";
					bar4 <= "0000001";
					bar5 <= "0000001";
					bar6 <= "0000001";
					cont_cron <= '1';
				end if;
				if(str='0' and cont_temp=0) then 
					cont_temp <= 1;					--- Ao pressionar str pela primeira vez, comeca a contagem		
				end if;
				if(cont_temp=1) then
					cronometro <= '1';				
				end if;
				if(str='0' and cont_temp=1) then
					cont_temp <= 2;					--- Estando ocorrendo a contagem e o str sendo pressionado o cronometro fica pausado
				end if;
				if(cont_temp=2) then
					cronometro <= '0';
				end if;
				if(cont_temp=2) then					--- Enquanto o cronometro estiver pausado he possivel apertar reset para zerar a contagem
					if(reset='0') then
						bar1 <= "0000001";
						bar2 <= "0000001";
						bar3 <= "0000001";
						bar4 <= "0000001";
						bar5 <= "0000001";
						bar6 <= "0000001";
						cont1_2<=0;
						cont2_2<=0;
						cont3_2<=0;
						cont4_2<=0;
						cont5_2<=0;
						cont6_2<=0;
					end if;
				end if;
				if(str='0' and cont_temp=2) then		--- Se o str for apertado e o cronometro estiver pausado, a contagem continua
					cont_temp <= cont_temp-1;
				end if;
			end if;
			---------------------------------------------------------- Analisa a ativacao do SINAL DE ALARME
			if(aux_estado6=cont6 and aux_estado5=cont5 and aux_estado4=cont4 and aux_estado3=cont3) then
				alarme <= "1111";
			end if;
			if(cont3 /= aux_estado3)then
				alarme <= "0000";
			end if;
		end if;	
		
		----------------------------------------- Conversao da contagem do RELOGIO para display7seg
		case cont1 is																		
			when 0 => BCD1_bar <= "0000001";										
			when 1 => BCD1_bar <= "1001111";										
			when 2 => BCD1_bar <= "0010010";										
			when 3 => BCD1_bar <= "0000110";										
			when 4 => BCD1_bar <= "1001100";										
			when 5 => BCD1_bar <= "0100100";										
			when 6 => BCD1_bar <= "0100000";									
			when 7 => BCD1_bar <= "0001111";									
			when 8 => BCD1_bar <= "0000000";								
			when 9 => BCD1_bar <= "0000100";										
			when others => BCD1_bar <= "0000001";									 
		end case;
		
		case cont2 is															
			when 0 => BCD2_bar <= "0000001";										
			when 1 => BCD2_bar <= "1001111";										
			when 2 => BCD2_bar <= "0010010";										
			when 3 => BCD2_bar <= "0000110";										
			when 4 => BCD2_bar <= "1001100";										
			when 5 => BCD2_bar <= "0100100";																				
			when others => BCD2_bar <= "0000001";								
		end case;
		
		case cont3 is															
			when 0 => BCD3_bar <= "0000001";										
			when 1 => BCD3_bar <= "1001111";										
			when 2 => BCD3_bar <= "0010010";										
			when 3 => BCD3_bar <= "0000110";										
			when 4 => BCD3_bar <= "1001100";										
			when 5 => BCD3_bar <= "0100100";										
			when 6 => BCD3_bar <= "0100000";									
			when 7 => BCD3_bar <= "0001111";									
			when 8 => BCD3_bar <= "0000000";								
			when 9 => BCD3_bar <= "0000100";										
			when others => BCD3_bar <= "0000001";	
		end case;
			
		case cont4 is															
			when 0 => BCD4_bar <= "0000001";										
			when 1 => BCD4_bar <= "1001111";										
			when 2 => BCD4_bar <= "0010010";										
			when 3 => BCD4_bar <= "0000110";										
			when 4 => BCD4_bar <= "1001100";										
			when 5 => BCD4_bar <= "0100100";	
			when others => BCD4_bar <= "0000001";
		end case;
	
		case cont5 is															
			when 0 => BCD5_bar <= "0000001";										
			when 1 => BCD5_bar <= "1001111";										
			when 2 => BCD5_bar <= "0010010";										
			when 3 => BCD5_bar <= "0000110";										
			when 4 => BCD5_bar <= "1001100";										
			when 5 => BCD5_bar <= "0100100";										
			when 6 => BCD5_bar <= "0100000";									
			when 7 => BCD5_bar <= "0001111";									
			when 8 => BCD5_bar <= "0000000";								
			when 9 => BCD5_bar <= "0000100";										
			when others => BCD5_bar <= "0000001";	
		end case;
		
		case cont6 is															
			when 0 => BCD6_bar <= "0000001";										
			when 1 => BCD6_bar <= "1001111";										
			when 2 => BCD6_bar <= "0010010";																			
			when others => BCD6_bar <= "0000001";									
		end case;
		
		----------------------------------------- Conversao da contagem do ALARME para display7seg
		case cont3_1 is															
			when 0 => BCD3_1_bar <= "0000001";										
			when 1 => BCD3_1_bar <= "1001111";										
			when 2 => BCD3_1_bar <= "0010010";										
			when 3 => BCD3_1_bar <= "0000110";										
			when 4 => BCD3_1_bar <= "1001100";										
			when 5 => BCD3_1_bar <= "0100100";										
			when 6 => BCD3_1_bar <= "0100000";									
			when 7 => BCD3_1_bar <= "0001111";									
			when 8 => BCD3_1_bar <= "0000000";								
			when 9 => BCD3_1_bar <= "0000100";										
			when others => BCD3_1_bar <= "0000001";	
		end case;
		
		case cont4_1 is															
			when 0 => BCD4_1_bar <= "0000001";										
			when 1 => BCD4_1_bar <= "1001111";										
			when 2 => BCD4_1_bar <= "0010010";										
			when 3 => BCD4_1_bar <= "0000110";										
			when 4 => BCD4_1_bar <= "1001100";										
			when 5 => BCD4_1_bar <= "0100100";	
			when others => BCD4_1_bar <= "0000001";
		end case;
		
		case cont5_1 is															
			when 0 => BCD5_1_bar <= "0000001";										
			when 1 => BCD5_1_bar <= "1001111";										
			when 2 => BCD5_1_bar <= "0010010";										
			when 3 => BCD5_1_bar <= "0000110";										
			when 4 => BCD5_1_bar <= "1001100";										
			when 5 => BCD5_1_bar <= "0100100";										
			when 6 => BCD5_1_bar <= "0100000";									
			when 7 => BCD5_1_bar <= "0001111";									
			when 8 => BCD5_1_bar <= "0000000";								
			when 9 => BCD5_1_bar <= "0000100";										
			when others => BCD5_1_bar <= "0000001";	
		end case;
		
		case cont6_1 is															
			when 0 => BCD6_1_bar <= "0000001";										
			when 1 => BCD6_1_bar <= "1001111";										
			when 2 => BCD6_1_bar <= "0010010";																			
			when others => BCD6_1_bar <= "0000001";									
		end case;
		
		----------------------------------------- Conversao da contagem do CRONOMETRO para display7seg
		case cont1_2 is																		
			when 0 => BCD1_2_bar <= "0000001";										
			when 1 => BCD1_2_bar <= "1001111";										
			when 2 => BCD1_2_bar <= "0010010";										
			when 3 => BCD1_2_bar <= "0000110";										
			when 4 => BCD1_2_bar <= "1001100";										
			when 5 => BCD1_2_bar <= "0100100";										
			when 6 => BCD1_2_bar <= "0100000";									
			when 7 => BCD1_2_bar <= "0001111";									
			when 8 => BCD1_2_bar <= "0000000";								
			when 9 => BCD1_2_bar <= "0000100";										
			when others => BCD1_2_bar <= "0000001";									 
		end case;
		
		case cont2_2 is															
			when 0 => BCD2_2_bar <= "0000001";										
			when 1 => BCD2_2_bar <= "1001111";										
			when 2 => BCD2_2_bar <= "0010010";										
			when 3 => BCD2_2_bar <= "0000110";										
			when 4 => BCD2_2_bar <= "1001100";										
			when 5 => BCD2_2_bar <= "0100100";																				
			when others => BCD2_2_bar <= "0000001";								
		end case;
		
		case cont3_2 is															
			when 0 => BCD3_2_bar <= "0000001";										
			when 1 => BCD3_2_bar <= "1001111";										
			when 2 => BCD3_2_bar <= "0010010";										
			when 3 => BCD3_2_bar <= "0000110";										
			when 4 => BCD3_2_bar <= "1001100";										
			when 5 => BCD3_2_bar <= "0100100";										
			when 6 => BCD3_2_bar <= "0100000";									
			when 7 => BCD3_2_bar <= "0001111";									
			when 8 => BCD3_2_bar <= "0000000";								
			when 9 => BCD3_2_bar <= "0000100";										
			when others => BCD3_2_bar <= "0000001";	
		end case;
			
		case cont4_2 is															
			when 0 => BCD4_2_bar <= "0000001";										
			when 1 => BCD4_2_bar <= "1001111";										
			when 2 => BCD4_2_bar <= "0010010";										
			when 3 => BCD4_2_bar <= "0000110";										
			when 4 => BCD4_2_bar <= "1001100";										
			when 5 => BCD4_2_bar <= "0100100";	
			when others => BCD4_2_bar <= "0000001";
		end case;
	
		case cont5_2 is															
			when 0 => BCD5_2_bar <= "0000001";										
			when 1 => BCD5_2_bar <= "1001111";										
			when 2 => BCD5_2_bar <= "0010010";										
			when 3 => BCD5_2_bar <= "0000110";										
			when 4 => BCD5_2_bar <= "1001100";										
			when 5 => BCD5_2_bar <= "0100100";										
			when 6 => BCD5_2_bar <= "0100000";									
			when 7 => BCD5_2_bar <= "0001111";									
			when 8 => BCD5_2_bar <= "0000000";								
			when 9 => BCD5_2_bar <= "0000100";										
			when others => BCD5_2_bar <= "0000001";	
		end case;
		
		case cont6_2 is															
			when 0 => BCD6_2_bar <= "0000001";										
			when 1 => BCD6_2_bar <= "1001111";										
			when 2 => BCD6_2_bar <= "0010010";																			
			when others => BCD6_2_bar <= "0000001";									
		end case;
	end process;
end architecture;
	