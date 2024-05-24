LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY top_level IS
	PORT(
		CLOCK_50, rst : IN STD_LOGIC;
		SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		GPIO_1 : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
		VGA_R, VGA_B, VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	   VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : OUT STD_LOGIC;
	   VGA_VS, VGA_HS : OUT STD_LOGIC;
		-- FOR testINg
		LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END top_level;

ARCHITECTURE impl OF top_level IS
	SIGNAL hpos, vpos : INTEGER;
	SIGNAL hsync, vsync, clock25, ff1_OUT, ff2_OUT, pixel_on_field, pixel_on_text, END_game : STD_LOGIC;
	SIGNAL mode, mode_temp : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL tank1_x, tank1_y : INTEGER;
	SIGNAL tank2_x, tank2_y : INTEGER;
	SIGNAL cpu1_x, cpu1_y : INTEGER;
	SIGNAL cpu2_x, cpu2_y : INTEGER;
	SIGNAL pixel_on_tank1 : STD_LOGIC;
	SIGNAL pixel_on_tank2 : STD_LOGIC;
	SIGNAL pixel_on_cpu_tank1 : STD_LOGIC;
	SIGNAL pixel_on_cpu_tank2 : STD_LOGIC;
	SIGNAL pixel_on_bullet : STD_LOGIC;
	-- Following signals are for the mode logic
	SIGNAL pixel_on_field_s : STD_LOGIC;
	SIGNAL pixel_on_tank1_s, pixel_on_tank2_s, pixel_on_cpu_tank1_s, pixel_on_cpu_tank2_s, pixel_on_bullet_s : STD_LOGIC;
	-- Tank stuff
	SIGNAL tank1_dir, tank2_dir : INTEGER := 0;
	SIGNAL hit_tank : STD_LOGIC := '0';

  signal tank1_bullet1_x : integer := 0;
  signal tank1_bullet1_y : integer := 0;
  signal tank1_bullet2_x : integer := 0;
  signal tank1_bullet2_y : integer := 0;
  signal tank1_bullet3_x : integer := 0;
  signal tank1_bullet3_y : integer := 0;
	
  signal tank2_bullet1_x : integer := 0;
  signal tank2_bullet1_y : integer := 0;
  signal tank2_bullet2_x : integer := 0;
  signal tank2_bullet2_y : integer := 0;
  signal tank2_bullet3_x : integer := 0;
  signal tank2_bullet3_y : integer := 0;
  
  signal cpu1_bullet1_x : integer := 0;
  signal cpu1_bullet1_y : integer := 0;
  signal cpu1_bullet2_x : integer := 0;
  signal cpu1_bullet2_y : integer := 0;
  signal cpu1_bullet3_x : integer := 0;
  signal cpu1_bullet3_y : integer := 0;
  
  signal cpu2_bullet1_x : integer := 0;
  signal cpu2_bullet1_y : integer := 0;
  signal cpu2_bullet2_x : integer := 0;
  signal cpu2_bullet2_y : integer := 0;
  signal cpu2_bullet3_x : integer := 0;
  signal cpu2_bullet3_y : integer := 0;
  
  SIGNAL cpu1_tank_x_start : INTEGER;
  SIGNAL cpu1_tank_y_start : INTEGER;
  SIGNAL cpu2_tank_x_start : INTEGER;
  SIGNAL cpu2_tank_y_start : INTEGER;
  
  SIGNAL tank1_x_start : INTEGER;
  SIGNAL tank1_y_start : INTEGER;
  SIGNAL tank2_x_start : INTEGER;
  SIGNAL tank2_y_start : INTEGER;
  
BEGIN
	END_game <= hit_tank;
	LEDR <= SW;  -- debug
	
	-- Clock
	clk_div:PROCESS(CLOCK_50) BEGIN
		IF (rst = '0') THEN
			clock25 <= '0';
		ELSIF (CLOCK_50'event AND CLOCK_50 = '1')then
			clock25 <= not clock25;
		END IF;
	END PROCESS;

	--VGA SIGNAL that must be active
	VGA_SYNC_N <= '1';
	VGA_BLANK_N <= '1';
	VGA_CLK <= clock25;

	ff1 : vDFF PORT MAP(hsync, clock25, '1', '0', rst, ff1_OUT);

	ff2 : vDFF PORT MAP(vsync, clock25, '1', '0', rst, ff2_OUT);

	ff3 : vDFF PORT MAP(ff1_OUT, clock25, '1', '0', rst, VGA_HS);

	ff4 : vDFF PORT MAP(ff2_OUT, clock25, '1', '0', rst, VGA_VS);
	
	--COMPONENTs PORT MAP
	vga_SIGNALs : vga_management PORT MAP(
		clk => clock25, rst => rst,
		hs => hsync, vs => vsync,
		hpos => hpos, vpos => vpos
	);
	
	dISplay_colORs : vgacolOR PORT MAP(
		clk => clock25, rst => rst,
		pixel_on_field => pixel_on_field,
		pixel_on_text => pixel_on_text,
		pixel_on_tank1 => pixel_on_tank1,
		pixel_on_tank2 => pixel_on_tank2,
		pixel_on_cpu_tank1 => pixel_on_cpu_tank1,
		pixel_on_cpu_tank2 => pixel_on_cpu_tank2,
		pixel_on_bullet => pixel_on_bullet,
		red => VGA_R, blue => VGA_B, green => VGA_G
	);
	
	menu : text_management PORT MAP(
		clk => clock25, rst => rst,
		hpos => hpos, vpos => vpos,
		mode => mode,
		pixel_on_text => pixel_on_text
	);
	
	modes : ModeFSM PORT MAP(
		clk => clock25, rstn => rst,
		END_game => END_game, SW => SW,
		GPIO_1 => GPIO_1,
		mode => mode_temp
	);
	
	game_field : field PORT MAP(
		clk => clock25, rstn => rst,
		xscan => hpos, yscan => vpos,
		flag => pixel_on_field_s
	);
	
	tank1 : tank port map(
		  clk => clock25,
		  rstn => rst,
		  xscan => hpos,
		  yscan => vpos,
		  x_pixel_ref => tank1_x,
		  y_pixel_ref => tank1_y,
		  x_start => tank1_x_start,
		  y_start => tank1_y_start,
		  SW_LEFT => not GPIO_1(13),
		  SW_RIGHT => not GPIO_1(17),
		  SW_FORWARD => not GPIO_1(15),
		  SW_SHOOT => not GPIO_1(11),
		  mode => mode,
		  flag => pixel_on_tank1_s,
		  dir_out => tank1_dir, 
		  bullet1_x => tank1_bullet1_x,
		  bullet1_y => tank1_bullet1_y,
		  bullet2_x => tank1_bullet2_x,
		  bullet2_y => tank1_bullet2_y,
		  bullet3_x => tank1_bullet3_x,
		  bullet3_y => tank1_bullet3_y
   );
	
	tank2 : tank port map(
		  clk => clock25,
		  rstn => rst,
		  xscan => hpos,
		  yscan => vpos,
		  x_pixel_ref => tank2_x,
		  y_pixel_ref => tank2_y,
		  x_start => tank2_x_start,
		  y_start => tank2_y_start,
		  SW_LEFT => not GPIO_1(3),
		  SW_RIGHT => not GPIO_1(7),
		  SW_FORWARD => not GPIO_1(5),
		  SW_SHOOT => not GPIO_1(1),
		  mode => mode,
		  flag => pixel_on_tank2_s,
		  dir_out => tank2_dir,
		  bullet1_x => tank2_bullet1_x,
		  bullet1_y => tank2_bullet1_y,
		  bullet2_x => tank2_bullet2_x,
		  bullet2_y => tank2_bullet2_y,
		  bullet3_x => tank2_bullet3_x,
		  bullet3_y => tank2_bullet3_y
   );

	
	
	cpu_tank1 : cpu_tank PORT MAP(
		clk => clock25,
		rstn => rst,
		xscan => hpos,
		yscan => vpos,
		x_pixel_ref => cpu1_x,
		y_pixel_ref => cpu1_y,
		player1_x_pixel_ref => tank1_x,
		player1_y_pixel_ref => tank1_y,
		player2_x_pixel_ref => tank2_x,
		player2_y_pixel_ref => tank2_y,
		x_start => cpu1_tank_x_start,
		y_start => cpu1_tank_y_start,
		mode => mode,
		flag => pixel_on_cpu_tank1_s,
		bullet1_x => cpu1_bullet1_x,
	  bullet1_y => cpu1_bullet1_y,
	  bullet2_x => cpu1_bullet2_x,
	  bullet2_y => cpu1_bullet2_y,
	  bullet3_x => cpu1_bullet3_x,
	  bullet3_y => cpu1_bullet3_y
	);
	
	cpu_tank2 : cpu_tank PORT MAP(
		clk => clock25,
		rstn => rst,
		xscan => hpos,
		yscan => vpos,
		x_pixel_ref => cpu2_x,
		y_pixel_ref => cpu2_y,
		player1_x_pixel_ref => tank1_x,
		player1_y_pixel_ref => tank1_y,
		player2_x_pixel_ref => tank2_x,
		player2_y_pixel_ref => tank2_y,
		x_start => cpu2_tank_x_start,
		y_start => cpu2_tank_y_start,
		mode => mode,
		flag => pixel_on_cpu_tank2_s,
		bullet1_x => cpu2_bullet1_x,
	  bullet1_y => cpu2_bullet1_y,
	  bullet2_x => cpu2_bullet2_x,
	  bullet2_y => cpu2_bullet2_y,
	  bullet3_x => cpu2_bullet3_x,
	  bullet3_y => cpu2_bullet3_y
	);
	
	-- Other Logic
	PROCESS(clock25, mode) BEGIN
	   IF rising_edge(clock25) THEN
		   mode <= mode_temp;
			IF (mode_temp = ONE_CPU_GAME) THEN
				tank1_x_start <= 80;
				tank1_y_start <= 80;
				tank2_x_start <= 80;
				tank2_y_start <= 400;
				
				cpu1_tank_x_start <= 500;
				cpu1_tank_y_start <= 200;
				cpu2_tank_x_start <= -1000;
				cpu2_tank_y_start <= -1000;
				pixel_on_field <= pixel_on_field_s;
				pixel_on_tank1 <= pixel_on_tank1_s;
				pixel_on_tank2 <= pixel_on_tank2_s;
				pixel_on_cpu_tank1 <= pixel_on_cpu_tank1_s;
				pixel_on_cpu_tank2 <= '0';
				pixel_on_bullet <= pixel_on_bullet_s;
			ELSIF (mode_temp = TWO_CPU_GAME) THEN
				tank1_x_start <= 80;
				tank1_y_start <= 80;
				tank2_x_start <= 80;
				tank2_y_start <= 400;
				cpu1_tank_x_start <= 500;
				cpu1_tank_y_start <= 80;
				cpu2_tank_x_start <= 500;
				cpu2_tank_y_start <= 400;
				pixel_on_field <= pixel_on_field_s;
				pixel_on_tank1 <= pixel_on_tank1_s;
				pixel_on_tank2 <= pixel_on_tank2_s;
				pixel_on_cpu_tank1 <= pixel_on_cpu_tank1_s;
				pixel_on_cpu_tank2 <= pixel_on_cpu_tank2_s;
				pixel_on_bullet <= pixel_on_bullet_s;
			ELSE 
				tank1_x_start <= -10000;
				tank1_y_start <= -10000;
				tank2_x_start <= 10000;
				tank2_y_start <= 10000;
				cpu1_tank_x_start <= -100000;
				cpu1_tank_y_start <= -100000;
				cpu2_tank_x_start <= 100000;
				cpu2_tank_y_start <= 100000;
				pixel_on_field <= '0';
				pixel_on_tank1 <= '0';
				pixel_on_tank2 <= '0';
				pixel_on_cpu_tank1 <= '0';
				pixel_on_cpu_tank2 <= '0';
				pixel_on_bullet <= '0';
			END IF;
		END IF;
	END PROCESS;

	
	-- Check if bullet hits tanks
	process(clock25) begin
    -- Reset hit_tank signal
    hit_tank <= '0';

    -- Check if tank1's bullet hits tank2
    if (tank1_bullet1_x >= tank2_x and tank1_bullet1_x <= tank2_x + 30 and
        tank1_bullet1_y >= tank2_y and tank1_bullet1_y <= tank2_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if tank1's bullet hits CPU1
    if (tank1_bullet1_x >= cpu1_x and tank1_bullet1_x <= cpu1_x + 30 and
        tank1_bullet1_y >= cpu1_y and tank1_bullet1_y <= cpu1_y + 30) then
        hit_tank <= '1';
    end if;
	 
	 -- Check if tank1's bullet hits CPU2
    if (tank1_bullet1_x >= cpu2_x and tank1_bullet1_x <= cpu2_x + 30 and
        tank1_bullet1_y >= cpu2_y and tank1_bullet1_y <= cpu2_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if tank2's bullet hits tank1
    if (tank2_bullet1_x >= tank1_x and tank2_bullet1_x <= tank1_x + 30 and
        tank2_bullet1_y >= tank1_y and tank2_bullet1_y <= tank1_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if tank2's bullet hits CPU1
    if (tank2_bullet1_x >= cpu1_x and tank2_bullet1_x <= cpu1_x + 30 and
        tank2_bullet1_y >= cpu1_y and tank2_bullet1_y <= cpu1_y + 30) then
        hit_tank <= '1';
    end if;
	 
	 -- Check if tank2's bullet hits CPU2
    if (tank2_bullet1_x >= cpu2_x and tank2_bullet1_x <= cpu2_x + 30 and
        tank2_bullet1_y >= cpu2_y and tank2_bullet1_y <= cpu2_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if CPU1's bullet hits tank1
    if (cpu1_bullet1_x >= tank1_x and cpu1_bullet1_x <= tank1_x + 30 and
        cpu1_bullet1_y >= tank1_y and cpu1_bullet1_y <= tank1_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if CPU1's bullet hits tank2
    if (cpu1_bullet1_x >= tank2_x and cpu1_bullet1_x <= tank2_x + 30 and
        cpu1_bullet1_y >= tank2_y and cpu1_bullet1_y <= tank2_y + 30) then
        hit_tank <= '1';
    end if;
	 
	 -- Check if CPU2's bullet hits tank1
    if (cpu2_bullet1_x >= tank1_x and cpu2_bullet1_x <= tank1_x + 30 and
        cpu2_bullet1_y >= tank1_y and cpu2_bullet1_y <= tank1_y + 30) then
        hit_tank <= '1';
    end if;

    -- Check if CPU2's bullet hits tank2
    if (cpu2_bullet1_x >= tank2_x and cpu2_bullet1_x <= tank2_x + 30 and
        cpu2_bullet1_y >= tank2_y and cpu2_bullet1_y <= tank2_y + 30) then
        hit_tank <= '1';
    end if;

end process;


END impl;