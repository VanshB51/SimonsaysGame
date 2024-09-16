library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

Entity simon_says is
	generic (
		seed : std_logic_vector(7 downto 0) := "10010110"
		);
	Port (
		CLOCK_50 : in STD_LOGIC;
		KEY  : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
		SW   : in  STD_LOGIC_VECTOR (17 DOWNTO 0);
		HEX0 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX1 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX2 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);		
		HEX3 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX4 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX5 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX6 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		HEX7 : OUT STD_LOGIC_VECTOR(6  DOWNTO  0);
		LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO  0);
		LEDG : OUT STD_LOGIC_VECTOR(4  DOWNTO  0)
		);
END simon_says;

Architecture Behavioural of simon_says is

--**************SIGNALS**************-- 

	SIGNAL rst         : STD_LOGIC;
	SIGNAL btn_db      : std_logic_vector(2 downto 0);
	SIGNAL slowclk     : STD_LOGIC;
	SIGNAL sigout      : signed(2 downto 0) := (others => '0');
	SIGNAL led_reg     : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others => '0');
	SIGNAL level       : integer:= 0 ;
	SIGNAL userlevel   : integer:= 1 ;
	SIGNAL mem_index   : integer:= 0 ;
	SIGNAL pattern     : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0');
	SIGNAL bitlevel    : STD_LOGIC_VECTOR(6 DOWNTO 0):= (others => '0');
	SIGNAL r_data_reg	 : std_logic_vector(2 downto 0):= (others => '0');
	SIGNAL points      : INTEGER := 0;
	signal disp_counter: integer := 0;
	SIGNAL bitpoints   : STD_LOGIC_VECTOR(6 DOWNTO 0):= (others => '0');
	CONSTANT MAX_LEVEL : INTEGER := 5;

--***************STATES***************--
	TYPE state_type IS (IDLE, SEQ_GEN , SEQ_DISP, USER_INP, CHECK_INP,CORR_INP, INCORR_INP, GAME_OVER);
	signal current_state : state_type;	
	
	type mem_2d_array is array (0 to 5) of std_logic_vector (2 downto 0);
	signal main_array_reg : mem_2d_array;
	signal user_array_reg : mem_2d_array;

--***********COMPONENTS************--

	component PreScale is 
	generic (dw : integer := 25);

	port (inCLOCK: in std_logic;
			outCLOCK: out std_logic); 
	end component;

	component debounce is
   generic
	(
	clk_freq :integer := 50_000_000;
	stable_time : integer:=10
	);
	Port (
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		button  : in STD_LOGIC;
		result: out STD_LOGIC
		);
   end component;
	
	component SegDecoder IS
	Port ( 
	D : in std_logic_vector( 3 downto 0 );
	Y : out std_logic_vector( 6 downto 0 ) 
	);
	END component;
	
   component rand_gen is
	port (
	clk :    in std_logic;
	rst :    in std_logic;
	PulseOut : out STD_LOGIC_VECTOR(2 DOWNTO 0));
	end component;
	
BEGIN

rst <= SW(17) and not KEY(3);
LEDR(17) <= rst;
prescale_1 : PreScale generic map (dw => 24) 
                               port map (inCLOCK => CLOCK_50, outCLOCK => slowclk);

debounce_0   : debounce port map (clk=> CLOCK_50, rst => rst, button => not KEY(0), result => btn_db(0));
debounce_1   : debounce port map (clk=> CLOCK_50, rst => rst, button => not KEY(1), result => btn_db(1));
debounce_2   : debounce port map (clk=> CLOCK_50, rst => rst, button => not KEY(2), result => btn_db(2));

rand_gen_0   : rand_gen   port map (clk => CLOCK_50,rst => rst, PulseOut => pattern);

--SegDecoder_0 : SegDecoder port map (D => std_logic_vector(to_unsigned(userlevel, 4)), Y => bitlevel);
--SegDecoder_1 : SegDecoder port map (D => std_logic_vector(to_unsigned(points, 4)), Y => bitpoints);


process(slowclk,rst)
	Begin
	
	if rst = '1' then
--reset all resgisters and goes into the idle state
	current_state<= IDLE;
	led_reg <= (others=> '0');
	main_array_reg <= (others=>(others=> '0'));
	user_array_reg <= (others=>(others=> '0'));
	level <= 0;
	userlevel <= 1;
	points <= 0;
	mem_index <= 0;
	r_data_reg <= (others=> '0');
	disp_counter<= 0;
	
	elsif rising_edge(slowclk) then
	-- game logic
	case current_state is
	when IDLE => 
	current_state <= SEQ_GEN;

	when SEQ_GEN => 
	
	IF level < 6 THEN
		main_array_reg(level) <= pattern;
		level<= level +1;
	END IF;
	IF level = 6 then
	level <= 0;
   current_state <= SEQ_DISP;
	end if;

	
	when  SEQ_DISP =>
	disp_counter <= disp_counter +1;
   
	if disp_counter < 7 then 
    led_reg <= main_array_reg(mem_index);
    mem_index <= mem_index + 1;
	 end if;
	 
  if disp_counter = 7 then
    if mem_index = 6 then 
        user_array_reg <= (others => (others => '0'));
        current_state <= USER_INP;
        led_reg <= (others => '0');
        mem_index <= 0;
		  disp_counter <= 0;  -- Reset the counter to start a new pattern
    end if;
	 end if;

   when USER_INP =>
  	if mem_index = 6 then
	current_state <= CHECK_INP;
	led_reg <= (others => '0');
	mem_index <= 0;
	end if;
	if KEY(0) = '0' then 
	--
	led_reg<= "001";
	user_array_reg(mem_index) <= "001";
	mem_index <= mem_index +1; 

	elsif KEY(1) = '0' then 
	
	led_reg<= "010";
	user_array_reg(mem_index) <= "010";
	mem_index <= mem_index +1; 
	
	elsif KEY(2) = '0' then 
	--
	led_reg<= "100";
	user_array_reg(mem_index) <= "100";
	mem_index <= mem_index +1; 
	
	end if;
	
	WHEN  CHECK_INP =>
	
	if main_array_reg(mem_index) /= user_array_reg(mem_index) then
	current_state <= INCORR_INP;
	mem_index <= 0;
	disp_counter<= 0;
	else 
		if mem_index = 5 then
		current_state <= CORR_INP; 
		mem_index <= 0;
		disp_counter <= 0;
		points <= points + 1;
		else
		mem_index <= mem_index +1;
		end if;
	   end if;
	
	WHEN CORR_INP =>
	      userlevel <= userlevel+1 ;
		if disp_counter<4 then
		disp_counter <= disp_counter+1;
		end if;
		if disp_counter = 4 then 
		current_state <= SEQ_GEN;
		disp_counter<=0;
		end if;
		
	WHEN INCORR_INP =>
	if disp_counter = 1 then
   led_reg<= "111";
	elsif disp_counter = 2 then
	led_reg<= "000";
	elsif disp_counter  = 3 then
	led_reg<= "111";
	else
	led_reg <= (others => '0');
	current_state <= GAME_OVER;
	end if;
	if disp_counter < 4 then
		disp_counter <= disp_counter+1;
	end if;
   WHEN GAME_OVER =>
	--
	current_state <= GAME_OVER;
	
	WHEN OTHERS => 
	current_state <= GAME_OVER;
	end case;
	
	end if;
	end process;
	
	
	--HEX0 <= bitpoints ; -- points
	HEX1 <= "1000000"; -- points
	HEX2 <= "1111111"; -- blank
	HEX3 <= "0001100" ;
	--HEX4 <= bitlevel; --level
	HEX5 <= "1000111" ;
	HEX6 <= "1001111";
	HEX7 <= "0010010" ;
	

  	LEDG(0) <= led_reg(0);
	LEDG(2) <= led_reg(1);
	LEDG(4) <= led_reg(2);

END Behavioural;