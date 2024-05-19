LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY text_management IS
    PORT (
        clk, rst : IN STD_LOGIC;
        hpos, vpos : IN INTEGER;
        mode : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pixel_on : OUT STD_LOGIC
    );
END text_management;

ARCHITECTURE behaviOR OF text_management IS
	SIGNAL pixel_on_tank_game, pixel_on_start, pixel_on_game_over, pixel_on_restart : STD_LOGIC;
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
	press_key_to_start : Pixel_On_Text
		GENERIC MAP(textLength => 38)
		PORT MAP(
			clk => clk,
			dISplayText => "Press Player 1 SHOOT to start the game",
			x => 167, y => 320,
			hORzCoORd => hpos,
			vertCoORd => vpos,
			pixel => pixel_on_start
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
		IF mode="00" then pixel_on <= pixel_on_tank_game OR pixel_on_start;
		ELSIF mode="10" then pixel_on <= pixel_on_game_over OR pixel_on_restart;
		END IF;
	END PROCESS;
END behaviOR;