LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;

package declarations IS
	-- D Flip Flop COMPONENTs
	COMPONENT vDFF IS
		PORT (
			D, Clk, Ld, Clr, Rstn : IN STD_LOGIC;
			Q : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT mDFF IS
		GENERIC(n: INTEGER := 1);
		PORT(
			clk, rstn: IN STD_LOGIC;
			D: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			Q: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
		);
	END COMPONENT;
	
	--Constants declaration with values assignment accORdINg to the VGA protocol 
    CONSTANT ha : INTEGER := 96;
    CONSTANT hb : INTEGER := 48;
    CONSTANT hc : INTEGER := 640;
    CONSTANT hd : INTEGER := 16;
    CONSTANT va : INTEGER := 2;
    CONSTANT vb : INTEGER := 33;
    CONSTANT vc : INTEGER := 480;
    CONSTANT vd : INTEGER := 10;
	
	-- States fOR ModeFSM
	constant MODE_STATE_WIDTH: INTEGER := 2;
	constant MAIN_MENU: STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0) := "00";
	constant GAME_STATE: STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0) := "01";
	constant GAME_OVER_SCREEN: STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0) := "10";
	-- ModeFSM COMPONENT
	COMPONENT ModeFSM IS
		PORT(clk, rstn, END_game : IN STD_LOGIC;
		     SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		     mode : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
	END COMPONENT;
	
	-- Text Management COMPONENT
	COMPONENT text_management IS
		PORT(
			clk, rst : IN STD_LOGIC;
			hpos, vpos : IN INTEGER;
			mode : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pixel_on : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- Pixel On Text COMPONENT
	COMPONENT Pixel_On_Text IS
        GENERIC(
            --Needed fOR INit dISplayText, the default value 11 IS just a rANDom number
            textLength : INTEGER := 11
        );
        PORT(
            clk : IN STD_LOGIC;
            dISplayText : IN STRING (1 TO textLength);
            --Top left cORner OF the text
            x : IN INTEGER;
            y : IN INTEGER;
            --Current pixel postion
            hORzCoORd : IN INTEGER;
            vertCoORd : IN INTEGER;
            pixel : OUT STD_LOGIC := '0'
        );
   END COMPONENT;
	 
	--C omponent USEd to manage the VGA synch SIGNALs (hs, vs) AND the scan SIGNALs on the screen (hpos, vpos)
	COMPONENT vga_management IS
		 PORT (
			  clk, rst : IN STD_LOGIC;
			  hs, vs : OUT STD_LOGIC;
			  hpos, vpos : BUFFER INTEGER
		 );
	END COMPONENT;
	
	-- COMPONENT to manage the VGA OUTputs
	COMPONENT vgacolOR IS
		PORT (
			clk, rst : IN STD_LOGIC;
			pixel_on, pixel_on_menu : IN STD_LOGIC;
			pixel_on_tank1, pixel_on_tank2 : IN STD_LOGIC;
			red, blue, green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;
	
	-- COMPONENT fOR Field
	COMPONENT field IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			xscan, yscan : IN INTEGER;
			flag : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- COMPONENT 
	COMPONENT tank IS
		PORT (
        clk, rstn : IN STD_LOGIC;
		  xscan, yscan : IN INTEGER;
		  x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
        x_start, y_start : IN INTEGER;
        SW_LEFT, SW_RIGHT : IN STD_LOGIC;
        mode : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        flag : OUT STD_LOGIC;
		  dir_OUT : OUT INTEGER
		 );
	END COMPONENT;
	
END package;