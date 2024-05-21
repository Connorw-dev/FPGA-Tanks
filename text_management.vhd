LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY text_management IS
    PORT (
        clk, rst : IN STD_LOGIC;
        hpos, vpos : IN INTEGER;
        mode : IN STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
        pixel_on : OUT STD_LOGIC
    );
END text_management;

ARCHITECTURE behaviOR OF text_management IS
	SIGNAL pixel_on_tank_game, pixel_on_one_cpu, pixel_on_two_cpu, pixel_on_game_over, pixel_on_restart : STD_LOGIC;
BEGIN
	tank_game : Pixel_On_Text
		GENERIC MAP(textLength => 31)
		PORT MAP(
			clk => clk,
			dISplayText => "CC4510 Design Project Tank Game",
			x => 195, y => 160,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_tank_game
		);
	P1_shoot_one_cpu_game : Pixel_On_Text
		GENERIC MAP(textLength => 56)
		PORT MAP(
			clk => clk,
			dISplayText => "Press Player 1 SHOOT to start the game with one CPU tank",
			x => 149, y => 320,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_one_cpu
		);
	P2_shoot_two_cpu_game : Pixel_On_Text
		GENERIC MAP(textLength => 57)
		PORT MAP(
			clk => clk,
			dISplayText => "Press Player 2 SHOOT to start the game with two CPU tanks",
			x => 148, y => 420,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_two_cpu
		);
	game_over : Pixel_On_Text
		GENERIC MAP(textLength => 9)
		PORT MAP(
			clk => clk,
			dISplayText => "GAME OVER",
			x => 275, y => 160,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_game_over
		);
	restart : Pixel_On_Text
		GENERIC MAP(textLength => 31)
		PORT MAP(
			clk => clk,
			dISplayText => "Press Player 2 SHOOT to restart",
			x => 195, y => 320,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_restart
		);

	enable_text : PROCESS(mode) BEGIN
		IF mode=MAIN_MENU then pixel_on <= pixel_on_tank_game OR pixel_on_one_cpu OR pixel_on_two_cpu;
		ELSIF mode=GAME_OVER_SCREEN then pixel_on <= pixel_on_game_over OR pixel_on_restart;
		END IF;
	END PROCESS;
END behaviOR;