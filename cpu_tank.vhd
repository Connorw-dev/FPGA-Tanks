LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.declarations.ALL;

ENTITY cpu_tank IS
	PORT(
		clk, rstn : IN STD_LOGIC;
		xscan, yscan : IN INTEGER;
		player1_x_pixel_ref, player1_y_pixel_ref, player2_x_pixel_ref, player2_y_pixel_ref : IN INTEGER;
		x_start, y_start : IN INTEGER;
		mode : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      flag : OUT STD_LOGIC
	);
END cpu_tank;

ARCHITECTURE impl OF cpu_tank is
	SIGNAL x_pixel_ref, y_pixel_ref : INTEGER;
	SIGNAL cpu_dir : INTEGER;
	SIGNAL SW_LEFT : STD_LOGIC := '0';
	SIGNAL SW_RIGHT : STD_LOGIC := '0';
	SIGNAL SW_FORWARD : STD_LOGIC := '0';
	SIGNAL shoot : STD_LOGIC;
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
		mode => mode,
		flag => flag,
		dir_OUT => cpu_dir
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
		shoot => shoot
	);
END impl;