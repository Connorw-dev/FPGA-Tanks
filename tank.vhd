LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY tank IS
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
END tank;

ARCHITECTURE behaviOR OF tank IS

    CONSTANT x_dim : INTEGER := 30;
    CONSTANT y_dim : INTEGER := 30;
    CONSTANT y_mIN : INTEGER := 0;
    CONSTANT y_MAX : INTEGER := 480;

    SIGNAL x_left, y_up : INTEGER := 80;
	 SIGNAL x_right, y_down : INTEGER := 130;
	 SIGNAL x_mid, y_mid : INTEGER := 15;
    SIGNAL cnt : INTEGER := 0;

	 SIGNAL dir : INTEGER := 0;
	 SIGNAL y_movement : INTEGER := 0;
	 SIGNAL x_movement : INTEGER := 0;
	 
	 SIGNAL half_tank_dim : INTEGER := 15;
	 SIGNAL nozzle_size : INTEGER := 10;
	 
	 SIGNAL IS_wALL : STD_LOGIC := '0';
	 SIGNAL x_pixel_ref_next, y_pixel_ref_next : INTEGER := 80;
	 
	 SIGNAL can_move : STD_LOGIC := '1';
	 SIGNAL SW_LEFT_last, SW_RIGHT_last : STD_LOGIC := '0';

BEGIN
    -- Values necessary to draw the racket
    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;
	 
	 
	 dir_OUT <= dir;
	 
	 x_mid <= x_left + half_tank_dim;
	 y_mid <= y_up + half_tank_dim;
	 
	 

    -- Draw tank
draw_tank : PROCESS (clk, rstn)
BEGIN
	 --flag <= '0';
    IF (rstn = '0' OR not mode = "01") THEN
        flag <= '0';
    ELSIF rISINg_edge(clk) THEN
			-- ThIS does not dISplay anythiINg
			IF (mode = GAME_STATE) THEN
					IF (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) THEN 
						flag <= '1'; 
					ELSIF (dir = 0 AND (xscan >= x_mid - nozzle_size/2) AND (xscan <= x_mid + nozzle_size/2) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) THEN
					  flag <= '1';
				 ELSIF (dir = 1 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) THEN
					  flag <= '1';
				 ELSIF (dir = 7 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) THEN
					  flag <= '1';
					  
				 ELSIF (dir = 2 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid - nozzle_size/2) AND (yscan <= y_mid + nozzle_size/2)) THEN
					  flag <= '1';
				 ELSIF (dir = 3 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) THEN
					  flag <= '1';
					  
				 ELSIF (dir = 6 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid - nozzle_size/2) AND (yscan <= y_mid + nozzle_size/2)) THEN
					  flag <= '1';
				 ELSIF (dir = 5 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) THEN
					  flag <= '1';
					  
				 ELSIF (dir = 4 AND (xscan >= x_mid - nozzle_size/2) AND (xscan <= x_mid + nozzle_size/2) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) THEN
					  flag <= '1';
					
					ELSE
						flag <= '0';
					END IF;
			ELSE
				flag <= '0';
			END IF;
    END IF;
END PROCESS;

    --Create a large loopINg counter to USE modulo-clocks
    create_counter : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' OR not mode = "01") THEN
            cnt <= 0;
        ELSIF rISINg_edge(clk) THEN
		       IF cnt < 10000000 THEN cnt <= cnt + 1; ELSE cnt <= 0; END IF;
        END IF;
    END PROCESS;
	 
	 -- PORT MAP field to check wALLs
		game_field : field PORT MAP(
			clk => clk, rstn => rstn,
			xscan => x_pixel_ref_next, yscan => y_pixel_ref_next,
			flag => IS_wALL
		);

    tank_movement_calculation : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' OR not mode = "01") THEN
				-- INitial position
				x_pixel_ref_next <= x_start;
            y_pixel_ref_next <= y_start;
        ELSIF rISINg_edge(clk) THEN
		  
		      -- Check direction to see how much the tank can move IN X AND Y
				-- dir 0 IS up, dir 1 IS NE, dir 2 IS E, etc.
		      -- Y
				IF ((dir = 7) OR (dir = 0) OR (dir = 1)) THEN
			      y_movement <= -1;
				ELSIF (dir = 3 OR dir = 4 OR dir = 5) THEN
				   y_movement <= 1;
				ELSE
					y_movement <= 0;
			   END IF;
				-- X
				IF ((dir = 5) OR (dir = 6) OR (dir = 7)) THEN
			      x_movement <= -1;
				ELSIF (dir = 1 OR dir = 2 OR (dir = 3)) THEN
				   x_movement <= 1;
				ELSE
					x_movement <= 0;
			   END IF;
				
				
				-- Movement
				-- Fast movement fOR vertical/hORizontal
				IF (cnt mod 100000 = 0) THEN
				  IF (dir = 0 OR dir = 2 OR dir = 4 OR dir = 6) THEN
					   IF (SW_LEFT = '1' AND SW_RIGHT = '1') THEN -- Need to add wALL check
							y_pixel_ref_next <= y_pixel_ref + y_movement;
							x_pixel_ref_next <= x_pixel_ref + x_movement;
						END IF;
					END IF;
				-- Slow movement fOR diagonals
				ELSIF (cnt mod 140000 = 0) THEN
					IF (dir = 1 OR dir = 3 OR dir = 5 OR dir = 7) THEN
					   IF (SW_LEFT = '1' AND SW_RIGHT = '1') THEN -- Need to add wALL check
							y_pixel_ref_next <= y_pixel_ref + y_movement;
							x_pixel_ref_next <= x_pixel_ref + x_movement;
						END IF;
					END IF;
				END IF;
								
			END IF;
    END PROCESS;
	 
	 turn_control : PROCESS (clk, rstn)
    BEGIN
        IF rstn = '0' THEN
            -- Reset the direction AND last states
            dir <= 0;
            SW_LEFT_last <= '0';
            SW_RIGHT_last <= '0';
        ELSIF rISINg_edge(clk) THEN
		     IF (cnt mod 100000 = 0) THEN
            -- Update the last states at each clock cycle
            SW_LEFT_last <= SW_LEFT;
            SW_RIGHT_last <= SW_RIGHT;
				-- INcrement dir WHEN SW_LEFT IS 0 AND SW_RIGHT has rISen from 0 to 1
            IF SW_LEFT = '0' AND SW_RIGHT_last = '0' AND SW_RIGHT = '1' THEN
                IF dir = 7 THEN dir <= 0; ELSE dir <= dir + 1; END IF;
            -- Decrement dir WHEN SW_RIGHT IS 0 AND SW_LEFT has rISen from 0 to 1
            ELSIF SW_RIGHT = '0' AND SW_LEFT_last = '0' AND SW_LEFT = '1' THEN
                IF dir = 0 THEN dir <= 7; ELSE dir <= dir - 1; END IF;
            END IF;
			 END IF;
			END IF;
	END PROCESS;
	 
	 -- CollISion check befORe movement update.
	 tank_position_update : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' OR not mode = "01") THEN
            x_pixel_ref <= x_start;
            y_pixel_ref <= y_start;
        ELSIF rISINg_edge(clk) THEN
            -- Check IF the new position collides with a wALL
            IF IS_wALL = '0' THEN
                x_pixel_ref <= x_pixel_ref_next;
                y_pixel_ref <= y_pixel_ref_next;
            END IF;
        END IF;
    END PROCESS;
END behaviOR;