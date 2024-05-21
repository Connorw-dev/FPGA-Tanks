LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.declarations.ALL;

ENTITY cpu_tank IS
	PORT(
		clk, rstn : IN STD_LOGIC;
		xscan, yscan : IN INTEGER;
		x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
		player1_x_pixel_ref, player1_y_pixel_ref, player2_x_pixel_ref, player2_y_pixel_ref : IN INTEGER;
		x_start, y_start : IN INTEGER;
		mode : IN STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
      flag : OUT STD_LOGIC;
	  bullet1_x, bullet1_y : OUT INTEGER;
	  bullet2_x, bullet2_y : OUT INTEGER;
	  bullet3_x, bullet3_y : OUT INTEGER
	);
END cpu_tank;

ARCHITECTURE impl OF cpu_tank is
	SIGNAL cpu_dir : INTEGER;
	SIGNAL SW_LEFT : STD_LOGIC := '0';
	SIGNAL SW_RIGHT : STD_LOGIC := '0';
	SIGNAL SW_FORWARD : STD_LOGIC := '0';
	SIGNAL SW_SHOOT : STD_LOGIC;
BEGIN
	-- Tank Component
	CPU_Tank : tank port map(
		clk => clk,
		rstn => rstn,
		xscan => xscan,
		yscan => yscan,
		x_pixel_ref => x_pixel_ref,
		y_pixel_ref => y_pixel_ref,
		x_start => x_start,
		y_start => y_start,
		SW_LEFT => SW_LEFT,
		SW_RIGHT => SW_RIGHT,
		SW_FORWARD => SW_FORWARD,
		SW_SHOOT => SW_SHOOT,
		mode => mode,
		flag => flag,
		dir_out => cpu_dir,
	  bullet1_x => bullet1_x,
	  bullet1_y => bullet1_y,
	  bullet2_x => bullet2_x,
	  bullet2_y => bullet2_y,
	  bullet3_x => bullet3_x,
	  bullet3_y => bullet3_y
	);
	
	-- CPU Controller Component
	CPU_Controller_C : cpu_controller port map(
		clk => clk,
		rstn => rstn,
		x_pixel_ref => x_pixel_ref,
		y_pixel_ref => y_pixel_ref,
		player1_x_pixel_ref => player1_x_pixel_ref,
		player1_y_pixel_ref => player1_y_pixel_ref,
		player2_x_pixel_ref => player2_x_pixel_ref,
		player2_y_pixel_ref => player2_y_pixel_ref,
		cpu_dir => cpu_dir,
		SW_LEFT => SW_LEFT,
		SW_RIGHT => SW_RIGHT,
		SW_FORWARD => SW_FORWARD,
		shoot => SW_SHOOT
	);
END impl;