LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.declarations.ALL;

ENTITY tank IS
    PORT (
        clk, rstn : IN STD_LOGIC;
		  xscan, yscan : IN INTEGER;
        x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
        x_start, y_start : IN INTEGER;
        SW_LEFT, SW_RIGHT, SW_FORWARD, SW_SHOOT : IN STD_LOGIC;
        mode : IN STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
			
        flag : OUT STD_LOGIC;
		  dir_out : OUT INTEGER;
		  bullet1_x, bullet1_y : OUT INTEGER;
		  bullet2_x, bullet2_y : OUT INTEGER;
		  bullet3_x, bullet3_y : OUT INTEGER
    );
END tank;

ARCHITECTURE behavior OF tank IS

    CONSTANT x_dim : INTEGER := 30;
    CONSTANT y_dim : INTEGER := 30;
    CONSTANT y_min : INTEGER := 0;
    CONSTANT y_MAX : INTEGER := 480;

    SIGNAL x_left, y_up : INTEGER := 80;
	 SIGNAL x_right, y_down : INTEGER := 130;
	 signal x_mid, y_mid : INTEGER := 15;
    SIGNAL cnt : INTEGER := 1;

	 SIGNAL dir : INTEGER := 0;
	 SIGNAL y_movement : INTEGER := 0;
	 SIGNAL x_movement : INTEGER := 0;
	 
	 SIGNAL half_tank_dim : INTEGER := 15;
	 SIGNAL nozzle_size : INTEGER := 10;
	 
	 SIGNAL is_wall : std_logic := '0';
	 signal x_pixel_ref_next, y_pixel_ref_next : integer := 80;
	  signal x_pixel_ref_temp, y_pixel_ref_temp : integer := 80;
	 
	 signal can_move : std_logic := '1';
	 signal SW_LEFT_last, SW_RIGHT_last : std_logic := '0';
	 signal SW_SHOOT_last : std_logic := '0';
	 
	 -- Corner coordinates for collision checking
		signal top_left_x, top_left_y : integer;
		signal top_right_x, top_right_y : integer;
		signal bottom_left_x, bottom_left_y : integer;
		signal bottom_right_x, bottom_right_y : integer;

		signal is_top_left_wall, is_top_right_wall, is_bottom_left_wall, is_bottom_right_wall : std_logic;
		
		signal bullet1_flag : std_logic := '0';
		signal bullet1_active : std_logic := '0';
		signal bullet1_want : std_logic := '0';
		signal bullet_start_x, bullet_start_y : integer := 0;
		signal bullet_dir : integer := 0;
		
		-- Clock dividers for different speeds
    SIGNAL slow_clk_div : INTEGER := 0;
    SIGNAL fast_clk_div : INTEGER := 0;
	 SIGNAL shoot_clk_div : INTEGER := 0;


BEGIN
    -- Values necessary to draw the tank
    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;
	 
	 
	 dir_out <= dir;
	 
	 
	 x_mid <= x_left + half_tank_dim;
	 y_mid <= y_up + half_tank_dim;
	 
	 
	 top_left_x <= x_pixel_ref_next;
	top_left_y <= y_pixel_ref_next;
	top_right_x <= x_pixel_ref_next + x_dim;
	top_right_y <= y_pixel_ref_next;
	bottom_left_x <= x_pixel_ref_next;
	bottom_left_y <= y_pixel_ref_next + y_dim;
	bottom_right_x <= x_pixel_ref_next + x_dim;
	bottom_right_y <= y_pixel_ref_next + y_dim;
	
	-- Process for generating slower clocks for diagonal movement
    slow_clock : PROCESS (clk, rstn)
    BEGIN
        IF rstn = '0' THEN
            slow_clk_div <= 0;
        ELSIF rising_edge(clk) THEN
            IF slow_clk_div < 140000 THEN
                slow_clk_div <= slow_clk_div + 1;
            ELSE
                slow_clk_div <= 0;
            END IF;
        END IF;
    END PROCESS;

    -- Process for generating faster clocks for horizontal/vertical movement
    fast_clock : PROCESS (clk, rstn)
    BEGIN
        IF rstn = '0' THEN
            fast_clk_div <= 0;
        ELSIF rising_edge(clk) THEN
            IF fast_clk_div < 100000 THEN
                fast_clk_div <= fast_clk_div + 1;
            ELSE
                fast_clk_div <= 0;
            END IF;
        END IF;
    END PROCESS;
	 
	 -- Process for generating faster clocks for horizontal/vertical movement
    shoot_clock : PROCESS (clk, rstn)
    BEGIN
        IF rstn = '0' THEN
            shoot_clk_div <= 0;
        ELSIF rising_edge(clk) THEN
            IF shoot_clk_div < 6250000 THEN
                shoot_clk_div <= shoot_clk_div + 1;
            ELSE
                shoot_clk_div <= 0;
            END IF;
        END IF;
    END PROCESS;
	
	
	process (dir)
	begin
	  case dir is
        when 0 =>
            bullet_start_x <= x_mid - nozzle_size / 2;
            bullet_start_y <= y_mid - 16 - nozzle_size;
        when 1 =>
            bullet_start_x <= x_mid + 16;
            bullet_start_y <= y_mid - nozzle_size - 16;
        when 2 =>
            bullet_start_x <= x_mid + 16;
            bullet_start_y <= y_mid - nozzle_size / 2;
        when 3 =>
            bullet_start_x <= x_mid + 16;
            bullet_start_y <= y_mid + 16;
        when 4 =>
            bullet_start_x <= x_mid - nozzle_size / 2;
            bullet_start_y <= y_mid + 16;
        when 5 =>
            bullet_start_x <= x_mid - 16 - nozzle_size;
            bullet_start_y <= y_mid + 16;
        when 6 =>
            bullet_start_x <= x_mid - 16 - nozzle_size;
            bullet_start_y <= y_mid - nozzle_size / 2;
        when 7 =>
            bullet_start_x <= x_mid - 16 - nozzle_size;
            bullet_start_y <= y_mid - nozzle_size - 16;
        when others =>
            bullet_start_x <= x_mid - nozzle_size / 2;
            bullet_start_y <= y_mid - 16 - nozzle_size;
    end case;
end process;
	 
	 

    -- Draw tank
draw_tank : PROCESS (clk, rstn)
BEGIN
	 --flag <= '0';
    IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN) THEN
        flag <= '0';
    ELSIF rising_edge(clk) THEN

				if (mode = ONE_CPU_GAME OR mode = TWO_CPU_GAME) THEN
				      -- draw tank square
						if (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) then 
							flag <= '1'; 
						-- draw tank nozzel
						elsif (dir = 0 AND (xscan >= x_mid - nozzle_size/2) AND (xscan <= x_mid + nozzle_size/2) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) then
						  flag <= '1';
					 elsif (dir = 1 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) then
						  flag <= '1';
					 elsif (dir = 7 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid - nozzle_size - 15) AND (yscan <= y_mid - 15)) then
						  flag <= '1';
						  
					 elsif (dir = 2 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid - nozzle_size/2) AND (yscan <= y_mid + nozzle_size/2)) then
						  flag <= '1';
					 elsif (dir = 3 AND (xscan >= x_mid + 15) AND (xscan <= x_mid + 15 + nozzle_size) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) then
						  flag <= '1';
						  
					 elsif (dir = 6 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid - nozzle_size/2) AND (yscan <= y_mid + nozzle_size/2)) then
						  flag <= '1';
					 elsif (dir = 5 AND (xscan >= x_mid - 15 - nozzle_size) AND (xscan <= x_mid - 15) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) then
						  flag <= '1';
						  
					 elsif (dir = 4 AND (xscan >= x_mid - nozzle_size/2) AND (xscan <= x_mid + nozzle_size/2) AND (yscan >= y_mid + 15) AND (yscan <= y_mid + 15 + nozzle_size)) then
						  flag <= '1';
					
					 -- BULLETS
					 elsif (bullet1_flag = '1') THEN
					     flag <= '1';
						
						else
							flag <= '0';
						end if;
				else
					flag <= '0';
				end if;
				
				
    END IF;
END PROCESS;

	 
		-- Port map four fields that check collision for each corner of tank
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
		
		
		-- BULLET ADD
		bullet1 : bullet port map(	  
			  clk => clk,
			  rstn => rstn,
			  xscan => xscan,
			  yscan => yscan,
			  x_pos_start=> bullet_start_x,
			  y_pos_start => bullet_start_y,
			  x_pos_out=> bullet1_x,
			  y_pos_out => bullet1_y,
			  direction => bullet_dir,
			  want_active => bullet1_want,
			  is_active => bullet1_active,
			  mode => mode,
			  flag => bullet1_flag
		);

    tank_movement_calculation : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN) THEN
				-- Initial position
				x_pixel_ref <= x_start;
			   y_pixel_ref <= y_start;
				
			   x_pixel_ref_temp <= x_start;
			   y_pixel_ref_temp <= y_start;
				
				x_pixel_ref_next <= x_start;
            y_pixel_ref_next <= y_start;
        ELSIF rising_edge(clk) THEN
		  
		      -- Check direction to see how much the tank can move in X and Y
				-- dir 0 is up, dir 1 is NE, dir 2 is E, etc.
		      -- Y
				IF ((dir = 7) or (dir = 0) or (dir = 1)) THEN
			      y_movement <= -1;
				ELSIF (dir = 3 or dir = 4 or dir = 5) THEN
				   y_movement <= 1;
				ELSE
					y_movement <= 0;
			   END IF;
				-- X
				IF ((dir = 5) or (dir = 6) or (dir = 7)) THEN
			      x_movement <= -1;
				ELSIF (dir = 1 or dir = 2 or (dir = 3)) THEN
				   x_movement <= 1;
				ELSE
					x_movement <= 0;
			   END IF;
				
				
				-- Movement
				-- Fast movement for vertical/horizontal
				IF (fast_clk_div = 0) THEN
				  IF (dir = 0 or dir = 2 or dir = 4 or dir = 6) THEN
					   IF (SW_FORWARD = '1') THEN -- Need to add wall check
							y_pixel_ref_next <= y_pixel_ref + y_movement;
							x_pixel_ref_next <= x_pixel_ref + x_movement;
						END IF;
					END IF;
				-- Slow movement for diagonals
				ELSIF (slow_clk_div = 0) THEN
					IF (dir = 1 or dir = 3 or dir = 5 or dir = 7) THEN
					   IF (SW_FORWARD = '1') THEN -- Need to add wall check
							y_pixel_ref_next <= y_pixel_ref + y_movement;
							x_pixel_ref_next <= x_pixel_ref + x_movement;
						END IF;
					END IF;
				end if;
				
				x_pixel_ref_temp <= x_pixel_ref_next;
				y_pixel_ref_temp <= y_pixel_ref_next;
				
				IF ((is_top_left_wall = '0') AND (is_top_right_wall = '0') AND (is_bottom_left_wall = '0') AND (is_bottom_right_wall = '0')) THEN
					 x_pixel_ref <= x_pixel_ref_temp;
					 y_pixel_ref <= y_pixel_ref_temp;
				END IF;
				
								
			END IF;
    END PROCESS;
	 

	 
	 turn_control : process (clk, rstn)
    begin
        if (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN) then
            -- Reset the direction and last states
            dir <= 0;
            SW_LEFT_last <= '0';
            SW_RIGHT_last <= '0';
        elsif rising_edge(clk) then
		     if (shoot_clk_div = 0) then
            -- Update the last states at each clock cycle
            SW_LEFT_last <= SW_LEFT;
            SW_RIGHT_last <= SW_RIGHT;
				if SW_LEFT = '1' and SW_RIGHT = '0' then
					if dir = 7 then dir <= 0; else dir <= dir + 1; end if;
				elsif SW_LEFT = '0' and SW_RIGHT = '1' then
					if dir = 0 then dir <= 7; else dir <= dir - 1; end if;
				end if;
				
				  
			 end if;
			end if;
	end process;
	 
	 
		
		-- SHOOT
		SHOOT : PROCESS (clk, rstn)
		begin
			if (rstn = '0' or mode = MAIN_MENU or mode = GAME_OVER_SCREEN) then
            SW_SHOOT_last <= '0';
        elsif rising_edge(clk) then

            -- Update the last states at each clock cycle
            SW_SHOOT_last <= SW_SHOOT;
				if SW_SHOOT_last = '0' and SW_SHOOT = '1' THEN
				  if (bullet1_active = '0') THEN
				      bullet_dir <= dir;
						bullet1_want <= '1';
				   else
					   bullet1_want <= '0';
				  end if;
			   else
				    bullet1_want <= '0';
				end if;
				
				  
			end if;
	end process;
			
END behavior;