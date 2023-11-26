library ieee;
use ieee.std_logic_1164.all;
use work.pacote.all;

entity simon is
	
	generic ( d: integer := 5000000; -- Tempo de 100 ms 
				 p: integer := 1000000; -- Tempo de 20 ms
				 e: integer := 50000000; -- Tempo de 1 s
				 m: integer := 25000000; -- Tempo de 500 ms
				 h: integer := 10000000; -- Tempo de 200 ms
				 T: integer := 250000000; -- Tempo de 5s
				 
			
				 clock_factor_1kHz: integer := 1000 * 50;
				interval_slider: integer := 500; -- ms
				message_1: string := "    TE351 - GENIUS";
				message_2: string := "    FIM DE JOGO";
				message_3: string := "    PARABENS";
				
				interval_ssd_driver: integer := 1; -- ms

        clock_factor_vga: integer := 1;
        h_bp: integer :=  64;
        h_aw: integer := 800;
        h_fp: integer :=  56;
        h_sp: integer := 120;
        v_bp: integer :=  23;
        v_aw: integer := 600;
        v_fp: integer :=  37;
        v_sp: integer :=   6;
        x_0: integer := 300;
        y_0: integer := 115;
        s_l: integer := 140;
        s_w: integer :=  30;
		  r_foreground: std_logic_vector(2 downto 0) := "000"; 
        g_foreground: std_logic_vector(2 downto 0) := "000";
        b_foreground: std_logic_vector(1 downto 0) := "00"
				 
				 ); 
	port ( clk, start, reset: in std_logic; -- Clock, Start e Reset
			 diff: in std_logic_vector (1 downto 0); -- Chaves seletoras de dificuldade
			 button: in std_logic_vector (3 downto 0); -- Push-buttons do jogo
			 leds: out std_logic_vector (3 downto 0); -- Leds de visualização
		  y: out std_logic_vector(0 to 7);
        s: out std_logic_vector(0 to 3);
        red: out std_logic_vector(2 downto 0);
        g: out std_logic_vector(2 downto 0);
        b: out std_logic_vector(1 downto 0);
        h_sync: out std_logic;
        v_sync: out std_logic
			 );
end entity;

architecture Behavioral of simon is

	signal clock_enable_1kHz: std_logic;
	signal enable_slider1: std_logic;
   signal x0_slider1, x1_slider1, x2_slider1, x3_slider1: std_logic_vector(0 to 6);

   signal enable_slider2: std_logic;
   signal x0_slider2, x1_slider2, x2_slider2, x3_slider2: std_logic_vector(0 to 6);
	
	signal enable_slider3: std_logic;
   signal x0_slider3, x1_slider3, x2_slider3, x3_slider3: std_logic_vector(0 to 6);
	
	signal x0_ssd, x1_ssd, x2_ssd, x3_ssd: std_logic_vector(0 to 6);

   signal clock_enable_vga: std_logic;
	signal x: std_logic_vector(0 to 16);

	signal key_delay: integer range 0 to T := 0; -- Delay máximo entre botões
	signal dly_delay: integer range 0 to d := d; -- Delay entre impressão de cores
	signal swt_delay: integer range 0 to p := p; -- Tempo de debouncing para os push-buttons
	signal seq_delay: integer range 0 to e := e; -- Tempo de impressão de cada cor
	signal sbt: integer range 1 to 14 := 1; -- Ponteiro de espera de botões
	signal n: integer range 0 to 14 := 0; -- Ponteiro de impressao de sequência
	signal lvl: integer range 1 to 14 := 1; -- Nível atual do jogo
	signal nibble: std_logic_vector (3 downto 0) := "0000"; -- Repassa o estado dos leds
	signal try: std_logic_vector (3 downto 0) := "0000"; -- Armazena a tentativa do jogador
	signal pr_state: states := idle; -- Estado da máquina
	signal future_state: states;
   signal r_background: std_logic_vector(2 downto 0) := "111";
   signal g_background: std_logic_vector(2 downto 0) := "111";
   signal b_background: std_logic_vector(1 downto 0) := "11";
	signal key_flag: std_logic :='0';
	signal dly_flag: std_logic :='0';
	signal swt_flag: std_logic :='0';
	signal seq_flag: std_logic :='0';
		
begin

	Timer1: entity work.Timer
        generic map (
            Freq => T
        )
        port map (
            rst => key_flag,
				clk => clk,
				output_timer => key_delay
        );
		  
	Timer2: entity work.Timer
        generic map (
            Freq => d
        )
        port map (
            rst => swt_flag,
				clk => clk,
				output_timer => swt_delay
        );	

		  Timer3: entity work.Timer
        generic map (
            Freq => p
        )
        port map (
            rst => dly_flag,
				clk => clk,
				output_timer => dly_delay
        );

       Timer4: entity work.Timer
        generic map (
            Freq => e
        )
        port map (
            rst => seq_flag,
				clk => clk,
				output_timer => seq_delay
        );		  
	
	frequency_divider_1kHz: entity work.frequency_divider
        generic map (
            clock_factor => clock_factor_1kHz
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_1kHz
        );
		  
	enable_slider1 <= '1' when pr_state = idle else '0';

    slider1: entity work.slider
        generic map (
            interval => interval_slider,
            message => message_1
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_1kHz,
            reset => reset,
            enable => enable_slider1,
            x0 => x0_slider1,
            x1 => x1_slider1,
            x2 => x2_slider1,
            x3 => x3_slider1
        );


    enable_slider2 <= '1' when pr_state = ff else '0';

    slider2: entity work.slider
        generic map (
            interval => interval_slider,
            message => message_2
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_1kHz,
            reset => reset,
            enable => enable_slider2,
            x0 => x0_slider2,
            x1 => x1_slider2,
            x2 => x2_slider2,
            x3 => x3_slider2
        );
		  
	 enable_slider3 <= '1' when pr_state = gg else '0';

    slider3: entity work.slider
        generic map (
            interval => interval_slider,
            message => message_3
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_1kHz,
            reset => reset,
            enable => enable_slider3,
            x0 => x0_slider3,
            x1 => x1_slider3,
            x2 => x2_slider3,
            x3 => x3_slider3
        );	  

    x0_ssd <= x0_slider1 when pr_state = idle else
              x0_slider2 when pr_state = ff else
				  x0_slider3 when pr_state = gg else
				  char_to_ssd(' ');

    x1_ssd <= x1_slider1 when pr_state = idle else
              x1_slider2 when pr_state = ff else
				  x1_slider3 when pr_state = gg else
				  "1111110" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl < 11 else
				  "0110000" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl >= 11 else
              char_to_ssd(' ');

    x2_ssd <= x2_slider1 when pr_state = idle else
              x2_slider2 when pr_state = ff else
				  x2_slider3 when pr_state = gg else
				  "1111110" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 1 else
				  "0110000" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 2 else
				  "1101101" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 3 else
				  "1111001" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 4 else
				  "0110011" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 5 else
				  "1011011" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 6 else
              "1011111" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 7 else
				  "1110000" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 8 else
				  "1111111" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 9 else
				  "1111011" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 10 else
				  "1111110" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 11 else
				  "0110000" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 12 else
				  "1101101" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 13 else
              "1111001" when (pr_state = print or pr_state = dly or pr_state = waiting or pr_state = upack or pr_state = dbc or pr_state = downack) and lvl = 14 else				 
				  char_to_ssd(' ');

    x3_ssd <= x3_slider1 when pr_state = idle else
              x3_slider2 when pr_state = ff else
				  x3_slider3 when pr_state = gg else
              char_to_ssd(' ');

    ssd_driver: entity work.ssd_driver
        generic map (
            interval => interval_ssd_driver
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_1kHz,
            x0 => x0_ssd,
            x1 => x1_ssd,
            x2 => x2_ssd,
            x3 => x3_ssd,
            y => y,
            s => s
        );


    frequency_divider_vga: entity work.frequency_divider
        generic map (
            clock_factor => clock_factor_vga
        )
        port map (
            clock => clk,
            clock_enable => clock_enable_vga
        );


    vga_driver: entity work.vga_driver
        generic map (
            h_bp => h_bp,
            h_aw => h_aw,
            h_fp => h_fp,
            h_sp => h_sp,
            v_bp => v_bp,
            v_aw => v_aw,
            v_fp => v_fp,
            v_sp => v_sp,
            x_0 => x_0,
            y_0 => y_0,
            s_l => s_l,
            s_w => s_w

        )
        port map (
            clock => clk,
            clock_enable => clock_enable_vga,
            x => x,
            r => red,
            g => g,
            b => b,
            h_sync => h_sync,
            v_sync => v_sync,
				r_foreground => r_foreground,
            g_foreground => g_foreground,
            b_foreground => b_foreground,
            r_background => r_background,
            g_background => g_background,
            b_background => b_background
        );		
		  
process(reset,clk)
begin
	if(reset='1') then
			pr_state <= idle;
	elsif rising_edge(clk) then
		pr_state <= future_state;
	end if;
end process;

	-- Processo que implementa a lógica de estados do jogo
	process(pr_state, start, seq_delay, diff, key_flag, dly_flag, swt_flag, seq_flag, key_delay, swt_delay, dly_delay, seq_delay )
	begin
	
--	if (reset = '1') then
--	
--		pr_state<=idle; -- Estado inicial em espera do jogo
--		
--	elsif (rising_edge(clk)) then
	
		

		-- Case dos estados da máquina 
		case pr_state is
		
		-- Estado inicial de espera da máquina
		when idle => leds<="1111";
						 nibble<="1111";
						 lvl<=1;
						 n<=0;	
						 sbt<=1;
						 key_flag<='1';
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='1';
						 
						-- r<=0;
						 
						 if ( start='1' ) then
							future_state<=print;
						 end if;
						 
		-- Estado que imprime as posições das sequências pré-definidas				 
	   when print => leds<=seq0(n);
						  nibble<=seq0(n);
						--  dly_delay<=d;
						  try<="0000";
						  key_flag<='1';
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='0';
						  
						  if ( seq_delay=e ) then
								future_state<=dly;	
						  end if;
						  
		-- Estado de delay entre a impressão de cada cor
		when dly => leds<="0000";
						nibble<="0000";
						key_flag<='1';
						 dly_flag<='0';
						 swt_flag<='1';
						 seq_flag<='1';
						
						if ( dly_delay=d ) then
							if ( n=lvl ) then
								future_state<=waiting;
							else
								future_state<=print;
								n<=n+1;
							end if;
						end if;
						
		-- Estado que aguarda que o jogador pressione um botão						
		when waiting => leds<="0000";
						    nibble<="0000";
						--	 swt_delay<=p;
							 key_flag<='0';
						    dly_flag<='1';
						    swt_flag<='1';
						    seq_flag<='1';
							 
							 if ( key_delay=T ) then
							future_state<=ff;
							 end if;
							 
							 if ( button/="0000" ) then
								try<=button;
								future_state<=upack;
							 end if;
							 
		-- Estado de debouncing para o reconhecimento da subida do botão					 
		when upack => leds<=button;
						  nibble<=button;
						  key_flag<='1';
						 dly_flag<='1';
						 swt_flag<='0';
						 seq_flag<='1';

						  if ( swt_delay=p ) then
								future_state<=dbc;
						  end if;	
 
		-- Estado que aguarda que o jogador solte o botão pressionado
		when dbc => leds<=button;
						nibble<=button;
					--	swt_delay<=p;
						key_flag<='0';
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='1';
						
						if ( key_delay=T ) then
							future_state<=ff;
						end if;
						
						if ( button="0000" ) then
							future_state<=downack;
						end if;
						
		-- Estado de debouncing para o reconhecimento da descida do botão
		-- Este estado também verifica se o botão correto foi pressionado
		when downack => leds<="0000";
							 nibble<="0000";
							 
						 dly_flag<='1';
						 swt_flag<='0';
						 seq_flag<='1';
							 
							 if ( swt_delay=p ) then
							--	key_delay<=T;
							key_flag<='1';
								if ( try=seq0(sbt) ) then
									if ( sbt=lvl ) then
										future_state<=nextlvl;
									else
										sbt<=sbt+1;
										future_state<=waiting;
									end if;
								else
									future_state<=ff;
								end if;
							 end if;			
							 
		-- Estado que incrementa o nível atual do jogo				
		when nextlvl => leds<="0000";
							 nibble<="0000";
							 key_flag<='1';
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='1';
		
							 if ( lvl=14 ) then
								future_state<=gg;
							 else
								future_state<=print;
								lvl<=lvl+1;
								n<=0;
								sbt<=1;
							 end if;
							 
		-- Estado final de vitória				
		when gg => leds<="1111";
					  nibble<="1111";
					  
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='1';
		
						if ( start='1' ) then
							future_state<=print;
							--key_delay<=T;
							key_flag<='1';
							lvl<=1;
							n<=0;
							sbt<=1;
							--r<=r+1;
							--if (r=9) then
						--		r<=0;
						--	end if;
						end if;
						
		-- Estado final de derrota
		when ff => leds<=try;
					  nibble<=try;
					 
						 dly_flag<='1';
						 swt_flag<='1';
						 seq_flag<='1';
					  
		
						 if ( start='1' ) then
							future_state<=print;
							--key_delay<=T;
							 key_flag<='1';
							lvl<=1;
							n<=0;
							sbt<=1;
						--	r<=r+1;
						--	if (r=9) then
						--		r<=0;
						--	end if;
						 end if;					

		end case;	
		
	--end if;
		
	end process;
	
	
	process (pr_state, lvl, nibble)
    begin
        case pr_state is
            when idle =>
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
                x <= "00000000000000000";
					 
				when print =>
				
					 if(nibble = "0001") then	
					 r_background <= "000";
                g_background <= "111";
                b_background <= "00";
					 x <= "10000000000000000";
					 
					 elsif(nibble = "0010") then
					 r_background <= "111";
                g_background <= "111";
                b_background <= "00";
					 x <= "10000000000000000";
					 
					 elsif(nibble = "0100") then
					 r_background <= "000";
                g_background <= "000";
                b_background <= "11";
					 x <= "10000000000000000";
					 
					 elsif(nibble = "1000") then
					 r_background <= "111";
                g_background <= "000";
                b_background <= "00";
					 x <= "10000000000000000";
					 
					 else
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "10000000000000000";
					 end if;
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
				when dly =>
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
					 
				when waiting =>
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
				when upack =>
				    r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000000";
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
				when dbc =>
				    r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000000";
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
				when downack =>
				    r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000000";
					 
					 if(lvl = 1) then
					 x <= "01000000000000000";
					 elsif(lvl = 2) then
					 x <= "00100000000000000";
					 elsif(lvl = 3) then
					 x <= "00010000000000000";
					  elsif(lvl = 4) then
					 x <= "00001000000000000";
					  elsif(lvl = 5) then
					 x <= "00000100000000000";
					  elsif(lvl = 6) then
					 x <= "00000010000000000";
					  elsif(lvl = 7) then
					 x <= "00000001000000000";
					  elsif(lvl = 8) then
					 x <= "00000000100000000";
					  elsif(lvl = 9) then
					 x <= "00000000010000000";
					  elsif(lvl = 10) then
					 x <= "00000000001000000";
					  elsif(lvl = 11) then
					 x <= "00000000000100000";
					  elsif(lvl = 12) then
					 x <= "00000000000010000";
					  elsif(lvl = 13) then
					 x <= "00000000000001000";
						elsif(lvl = 14) then
					 x <= "00000000000000100";
					 end if;
				when nextlvl =>
				    r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000000";
				when gg =>
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000010";
				when ff =>
					 r_background <= "111";
                g_background <= "111";
                b_background <= "11";
					 x <= "00000000000000001";		
        end case;
    end process;
	 
--	 -- Verificação da posição das chaves de dificuldade e atribuição ao sinal
--		if ( diff="00" ) then
--			seq_delay<=e;
--		elsif ( diff="01" ) then
--			seq_delay<=m;
--		elsif ( diff="10" ) then
--			seq_delay<=h;
--		else
--			seq_delay<=e;
--		end if;

	-- Associação dos componentes com os respectivos E/S e sinais internos
	--disp: Decoder port map(clk, reset, display, anode, pr_state, lvl);
	--monitor: VGA port map (clk, reset, nibble, lvl, pr_state, h_sync, v_sync, red, green, blue);

end Behavioral;