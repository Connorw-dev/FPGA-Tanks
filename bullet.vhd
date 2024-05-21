LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.declarations.ALL;

ENTITY bullet IS
    PORT (		  
        clk, rstn : in std_logic;
		  mode : IN STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
		  x_pos_start, y_pos_start : in integer;
        x_pos_out, y_pos_out : out integer;
        direction : in integer range 0 to 7;
		  want_active : in std_logic;
        is_active : out std_logic;
		  xscan, yscan : IN INTEGER;
        flag : OUT STD_LOGIC
    );
END bullet;

ARCHITECTURE behavior OF bullet IS
	--------------- Define variables -----------------
	
	CONSTANT bullet_size : INTEGER := 10; -- Diameter of square bullet
	CONSTANT x_off, y_off : INTEGER := 200; -- position when bullet is inactive
	
	-- Variable for modulo clocks
	SIGNAL cnt : INTEGER := 0;
	
	-- Variables required for drawing square
	SIGNAL x_left, y_up : INTEGER := 200;
	SIGNAL x_right, y_down : INTEGER := 200;
	
	-- Variables for movement
	SIGNAL y_movement : INTEGER := 0;
	SIGNAL x_movement : INTEGER := 0;
	
	-- Extra variables for position. Needed to check for collision before updating.
	signal x_pos_next, y_pos_next : integer := 200;
	signal x_pos_temp, y_pos_temp : integer := 200;
	
	-- Corner coordinates for collision checking
	signal top_left_x, top_left_y : integer;
	signal top_right_x, top_right_y : integer;
	signal bottom_left_x, bottom_left_y : integer;
	signal bottom_right_x, bottom_right_y : integer;
	signal is_top_left_wall, is_top_right_wall, is_bottom_left_wall, is_bottom_right_wall : std_logic;
	
	signal x_pos : integer := 400;
	signal y_pos : integer := 200;
	
	signal active_now : std_logic := '0';
	signal want_delete : std_logic := '0';
	BEGIN
	
	
	
	------------------- Variable updates ---------------
	
	is_active <= active_now;
	
	-- Calculate sides for drawing
	x_pos_out <= x_pos;
	y_pos_out <= y_pos;
	
	x_left <= x_pos;
	x_right <= x_pos + bullet_size;
	y_up <= y_pos;
	y_down <= y_pos + bullet_size;

	-- Calculate corner positions
	top_left_x <= x_pos_next;
	top_left_y <= y_pos_next;
	top_right_x <= x_pos_next + bullet_size;
	top_right_y <= y_pos_next;
	bottom_left_x <= x_pos_next;
	bottom_left_y <= y_pos_next + bullet_size;
	bottom_right_x <= x_pos_next + bullet_size;
	bottom_right_y <= y_pos_next + bullet_size;
	
	---------------------- Port maps ----------------------
	
	-- Add four game fields to check wall collision of each bullet corner 
	game_field_top_left : field port map(
		 clk => clk, rstn => rstn,
		 xscan => top_left_x, yscan => top_left_y,
		 flag => is_top_left_wall
	);

	game_field_top_right : field port map(
		 clk => clk, rstn => rstn,
		 xscan => top_right_x, yscan => top_right_y,
		 flag => is_top_right_wall
	);

	game_field_bottom_left : field port map(
		 clk => clk, rstn => rstn,
		 xscan => bottom_left_x, yscan => bottom_left_y,
		 flag => is_bottom_left_wall
	);

	game_field_bottom_right : field port map(
		 clk => clk, rstn => rstn,
		 xscan => bottom_right_x, yscan => bottom_right_y,
		 flag => is_bottom_right_wall
	);

	
	------------------ Processes -----------------------
	
	become_active : process (clk, rstn)
begin
    if rstn = '0' then
        active_now <= '0';
    elsif rising_edge(clk) then
        if (want_active = '1') then
            active_now <= '1';
        
		  elsif (want_delete = '1') then
		      active_now <= '0';
				
		 end if;
    end if;
end process;
	
	-- Draw bullet
	draw : PROCESS (clk, rstn)
	BEGIN
		IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN or active_now = '0') THEN
			flag <= '0';
		ELSIF rising_edge(clk) THEN
			if (mode = ONE_CPU_GAME OR mode = TWO_CPU_GAME) THEN
				-- draw bullet square
				if (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) then 
					flag <= '1'; 
				else
					flag <= '0';
				end if;
			else
				flag <= '0';
			end if;
		 END IF;
	END PROCESS;
	
	--Create a large looping counter to use modulo-clocks
    create_counter : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN) THEN
            cnt <= 0;
        ELSIF rising_edge(clk) THEN
		       if cnt < 1000000 then cnt <= cnt + 1; else cnt <= 0; end if;
        END IF;
    END PROCESS;
	
	-- Calculate next position
	movement_calculation : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN or active_now = '0') THEN
				-- Initial position
				x_pos_next <= x_pos;
            y_pos_next <= y_pos;
        ELSIF rising_edge(clk) THEN
		  
		      -- Check directionection to see how much the bullet can move in X and Y
				-- direction 0 is up, direction 1 is NE, direction 2 is E, etc.
		      -- Y
				IF ((direction = 7) or (direction = 0) or (direction = 1)) THEN
			      y_movement <= -1;
				ELSIF (direction = 3 or direction = 4 or direction = 5) THEN
				   y_movement <= 1;
				ELSE
					y_movement <= 0;
			   END IF;
				-- X
				IF ((direction = 5) or (direction = 6) or (direction = 7)) THEN
			      x_movement <= -1;
				ELSIF (direction = 1 or direction = 2 or (direction = 3)) THEN
				   x_movement <= 1;
				ELSE
					x_movement <= 0;
			   END IF;
				
				
				-- Movement
				-- Fast movement for vertical/horizontal
					IF (cnt mod 100000 = 0) THEN
					  IF (direction = 0 or direction = 2 or direction = 4 or direction = 6) THEN
					  
								y_pos_next <= y_pos + y_movement;
								x_pos_next <= x_pos + x_movement;
						END IF;
					-- Slow movement for diagonals
					ELSIF (cnt mod 140000 = 0) THEN
						IF (direction = 1 or direction = 3 or direction = 5 or direction = 7) THEN
								y_pos_next <= y_pos + y_movement;
								x_pos_next <= x_pos + x_movement;
						END IF;
					end if;
								
			END IF;
    END PROCESS;
	
	-- Collision check before movement update.
	 position_update : PROCESS (clk, rstn)
		BEGIN
			 IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN or active_now = '0') THEN
				  x_pos <= x_pos_start;
				  y_pos <= y_pos_start;
				  x_pos_temp <= x_pos;
				  y_pos_temp <= y_pos;
			 ELSIF rising_edge(clk) THEN
				  -- Update temp vars first
				  x_pos_temp <= x_pos_next;
				  y_pos_temp <= y_pos_next;

				  -- Check collision using temp vars
				  IF (is_top_left_wall = '0') AND (is_top_right_wall = '0') AND (is_bottom_left_wall = '0') AND (is_bottom_right_wall = '0') THEN
						 x_pos <= x_pos_temp;
						 y_pos <= y_pos_temp;
						 want_delete <= '0';
					ELSE
					    want_delete <= '1';
					END IF;
			 END IF;
		END PROCESS;
	
END behavior;