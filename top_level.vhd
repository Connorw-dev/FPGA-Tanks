LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY top_level IS
	PORT(
		CLOCK_50, rst : IN STD_LOGIC;
		SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		VGA_R, VGA_B, VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	   VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : OUT STD_LOGIC;
	   VGA_VS, VGA_HS : OUT STD_LOGIC;
		-- FOR testINg
		LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END top_level;

ARCHITECTURE impl OF top_level IS
	SIGNAL hpos, vpos : INTEGER;
	SIGNAL hsync, vsync, clock25, ff1_OUT, ff2_OUT, pixel_on_game, pixel_on_text, END_game : STD_LOGIC;
	SIGNAL mode : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL tank1_x, tank1_y : INTEGER := 80;
	SIGNAL tank2_x, tank2_y : INTEGER := 80;
	SIGNAL pixel_on_tank1 : STD_LOGIC;
	SIGNAL pixel_on_tank2 : STD_LOGIC;
	SIGNAL pixel_on_game_s : STD_LOGIC;  -- SIGNAL fOR pixel on game
	SIGNAL pixel_on_tank1_s, pixel_on_tank2_s : STD_LOGIC;  -- SIGNALs fOR pixel on tanks
	
	SIGNAL tank1_dir, tank2_dir : INTEGER := 0;
BEGIN
	-- FOR TESTING
	END_game <= SW(1);
	--pixel_on_game <= '0';
	LEDR <= SW;
	
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
		pixel_on => pixel_on_game, pixel_on_menu => pixel_on_text, pixel_on_tank1 => pixel_on_tank1, pixel_on_tank2 => pixel_on_tank2,
		red => VGA_R, blue => VGA_B, green => VGA_G
	);
	
	menu : text_management PORT MAP(
		clk => clock25, rst => rst,
		hpos => hpos, vpos => vpos,
		mode => mode,
		pixel_on => pixel_on_text
	);
	
	modes : ModeFSM PORT MAP(
		clk => clock25, rstn => rst,
		END_game => END_game, SW => SW,
		mode => mode
	);
	
	game_field : field PORT MAP(
		clk => clock25, rstn => rst,
		xscan => hpos, yscan => vpos,
		flag => pixel_on_game_s
	);
	
	tank1 : tank PORT MAP(
		  clk => clock25,
		  rstn => rst,
		  xscan => hpos,
		  yscan => vpos,
		  x_pixel_ref => tank1_x,
		  y_pixel_ref => tank1_y,
		  x_start => 80,
		  y_start => 80,
		  SW_LEFT => SW(9),
		  SW_RIGHT => SW(8),
		  mode => mode,
		  flag => pixel_on_tank1_s,
		  dir_OUT => tank1_dir
   );
	
	tank2 : tank PORT MAP(
		  clk => clock25,
		  rstn => rst,
		  xscan => hpos,
		  yscan => vpos,
		  x_pixel_ref => tank2_x,
		  y_pixel_ref => tank2_y,
		  x_start => 80,
		  y_start => 80,
		  SW_LEFT => SW(7),
		  SW_RIGHT => SW(6),
		  mode => mode,
		  flag => pixel_on_tank2_s,
		  dir_OUT => tank2_dir
   );
	
	-- Other Logic
	PROCESS(mode) BEGIN
		IF (mode = "01") then 
			pixel_on_game <= pixel_on_game_s;
			pixel_on_tank1 <= pixel_on_tank1_s;
			pixel_on_tank2 <= pixel_on_tank2_s;
		ELSE 
			pixel_on_game <= '0';
			pixel_on_tank1 <= '0';
			pixel_on_tank2 <= '0';
		END IF;
	END PROCESS;
END impl;