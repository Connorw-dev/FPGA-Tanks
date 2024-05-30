-----------------------------------------------------------------------------
-- File Name: field.vhd
-- Description: Returns whether an x,y coordinate is part of the field/wall.
-----------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.declarations.ALL;

ENTITY field IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        xscan, yscan : IN INTEGER;
		  mode : IN STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 downto 0);
        flag : OUT STD_LOGIC
    );
END field;

ARCHITECTURE behaviour OF field IS
	 -- DEFINE CONSTANTS
	 CONSTANT X_MIN : INTEGER := 0;
	 CONSTANT Y_MIN : INTEGER := 0;
	 CONSTANT X_MAX : INTEGER := 640;
    CONSTANT Y_MAX : INTEGER := 480;
	 CONSTANT BORDER_SIZE : INTEGER := 30;
	 
	-- Define the record type for a basic rectangular wall
	type wall_type is record
		 x_left   : integer;
		 x_right  : integer;
		 y_top    : integer;
		 y_bottom : integer;
	end record;
	
	-- Declare and initialiSe the array of walls
	type wall_array_type is array (natural range <>) of wall_type;
	constant walls : wall_array_type := (
		(x_left => X_MIN, x_right => BORDER_SIZE, y_top => Y_MIN, y_bottom => Y_MAX), 		  -- Left border
		(x_left => X_MIN, x_right => X_MAX, y_top => Y_MIN, y_bottom => BORDER_SIZE),			  -- Top border
		(x_left => X_MAX - BORDER_SIZE, x_right => X_MAX, y_top => Y_MIN, y_bottom => Y_MAX), -- Right border
		(x_left => X_MIN, x_right => X_MAX, y_top => Y_MAX-BORDER_SIZE, y_bottom => Y_MAX),   -- Bottom border

		(x_left => 150, x_right => 200, y_top => Y_MIN, y_bottom => 160),  -- Wall one
		(x_left => 150, x_right => 200, y_top => 320, y_bottom => Y_MAX),  -- Wall two
		(x_left => 300, x_right => 350, y_top => 160, y_bottom => 320)     -- Wall three
	);

	BEGIN
	
	-- Process to detect if a wall is on the given coords
	detect_wall : PROCESS (clk, rstn)
		variable i : integer;
		BEGIN
			 IF rstn = '0' THEN
				  flag <= '0'; 
			 ELSIF rising_edge(clk) THEN
				  flag <= '0';  -- Default no wall

				     -- TODO: Use different fields for different game modes.
					  -- Loop through each wall and check
					  for i in walls'range loop
							IF (xscan > walls(i).x_left AND xscan < walls(i).x_right AND
								 yscan > walls(i).y_top AND yscan < walls(i).y_bottom) THEN
								 flag <= '1';
								 exit;  -- Exit if wall found.
							END IF;
					  end loop;
				  
			 END IF;
	END PROCESS;
END behaviour;