LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

--COMPONENT to manage the VGA OUTputs
ENTITY vgacolOR IS
	PORT (
		clk, rst : IN STD_LOGIC;
		pixel_on, pixel_on_menu, pixel_on_tank1, pixel_on_tank2 : IN STD_LOGIC;
		red, blue, green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END vgacolOR;

ARCHITECTURE behaviOR OF vgacolOR IS

BEGIN

	--Turns on pixELS to view images on the screen
	dISplay_ALL : PROCESS (clk, rst)
	BEGIN
		IF (rst = '0') THEN
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
		   IF (pixel_on_tank1 = '1') THEN
			   red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '1'); 
			ELSIF (pixel_on_tank2 = '1') THEN
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '0');
			ELSIF (pixel_on = '1' OR pixel_on_menu = '1') THEN
				red <= (OTHERS => '1');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '1');
			ELSE
				red <= (OTHERS => '0');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

END behaviOR;