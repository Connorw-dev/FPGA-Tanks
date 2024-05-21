LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.declarations.ALL;

ENTITY cpu_controller IS
    PORT(
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : IN INTEGER;
        player1_x_pixel_ref, player1_y_pixel_ref : IN INTEGER;
        player2_x_pixel_ref, player2_y_pixel_ref : IN INTEGER;
        cpu_dir : IN INTEGER;
        SW_LEFT, SW_RIGHT, SW_FORWARD : OUT STD_LOGIC;
        shoot : OUT STD_LOGIC
    );
END cpu_controller;

ARCHITECTURE impl OF cpu_controller IS
    SIGNAL closest_tank : STD_LOGIC;
    SIGNAL dist1, dist2 : INTEGER;
    SIGNAL target_dir : INTEGER;
	 SIGNAL P1_center_x, P1_center_y, P2_center_x, P2_center_y, CPU1_center_x, CPU1_center_y : INTEGER;
	 SIGNAL cur_state : STD_LOGIC_VECTOR(CPU_CONTROLLER_STATE_WIDTH-1 DOWNTO 0) := IDLE;
	 SIGNAL nxt_state, nxt_state1 : STD_LOGIC_VECTOR(CPU_CONTROLLER_STATE_WIDTH-1 DOWNTO 0);
	 SIGNAL shoot_s : STD_LOGIC := '1';

    -- Function to calculate direction based on coordinates
    FUNCTION get_direction(player_x, player_y, cpu_x, cpu_y : INTEGER) RETURN INTEGER IS
        VARIABLE dx : INTEGER;
        VARIABLE dy : INTEGER;
        VARIABLE direction : INTEGER;
    BEGIN
        dx := player_x - cpu_x;
        dy := player_y - cpu_y;

        IF dx > -distance_threshold AND dx < distance_threshold THEN
            IF dy < 0 THEN
                direction := 0; -- North
            ELSE
                direction := 4; -- South
            END IF;
        ELSIF dy > -distance_threshold AND dy < distance_threshold THEN
            IF dx > 0 THEN
                direction := 2; -- East
            ELSE
                direction := 6; -- West
            END IF;
        ELSE
            IF dx > distance_threshold AND dy < -distance_threshold THEN
                direction := 1; -- North-East
            ELSIF dx > distance_threshold AND dy > distance_threshold THEN
                direction := 3; -- South-East
            ELSIF dx < -distance_threshold AND dy > distance_threshold THEN
                direction := 5; -- South-West
            ELSE
                direction := 7; -- North-West
            END IF;
        END IF;

        RETURN direction;
    END get_direction;

BEGIN
    -- Tank Center Positions
	 P1_center_x <= player1_x_pixel_ref + TANK_SIZE / 2;
	 P1_center_y <= player1_y_pixel_ref + TANK_SIZE / 2;
	 P2_center_x <= player2_x_pixel_ref + TANK_SIZE / 2;
	 P2_center_y <= player2_y_pixel_ref + TANK_SIZE / 2;
	 CPU1_center_x <= x_pixel_ref + TANK_SIZE / 2;
	 CPU1_center_y <= y_pixel_ref + TANK_SIZE / 2;
	 
	 -- Movement
    SW_FORWARD <= '0';
	 
	 -- Shooting
	SHOOTS : PROCESS(
		clk, rstn
	)
	BEGIN
		IF rising_edge(clk) THEN
			IF rstn = '0' THEN
				shoot_s <= '0';
			ELSE
				shoot_s <= NOT shoot_s;
			END IF;
		END IF;
	END PROCESS;
	shoot <= shoot_s;
 
    -- Calculate Closest Player Tank
	CLOSEST_TANK_P : PROCESS(
		clk, rstn
	)
	BEGIN
			IF rstn = '0' THEN
				 closest_tank <= '0';
			ELSE
				 -- Calculate squared distances
				 dist1 <= (P1_center_x - CPU1_center_x) * (P1_center_x - CPU1_center_x) + 
							 (P1_center_y - CPU1_center_y) * (P1_center_y - CPU1_center_y);
							 
				 dist2 <= (P2_center_x - CPU1_center_x) * (P2_center_x - CPU1_center_x) + 
							 (P2_center_y - CPU1_center_y) * (P2_center_y - CPU1_center_y);

				 -- Compare distances
				 IF dist1 <= dist2 THEN
					  closest_tank <= '0';
				 ELSE
					  closest_tank <= '1';
				 END IF;
			END IF;
    END PROCESS;
    
    -- Calculate Direction for CPU Tank to Face
	TANK_DIR : PROCESS(
		closest_tank,
		player1_x_pixel_ref, player1_y_pixel_ref,
		player2_x_pixel_ref, player2_y_pixel_ref,
		x_pixel_ref, y_pixel_ref
	) 
	BEGIN
        IF closest_tank = '0' THEN
            target_dir <= get_direction(P1_center_x, P1_center_y, CPU1_center_x, CPU1_center_y);
        ELSE
            target_dir <= get_direction(P2_center_x, P2_center_y, CPU1_center_x, CPU1_center_y);
        END IF;
    END PROCESS;
	
	-- ROTATE CPU tank to face the closest player tank
	-- State register
	UPDATE_DIR_STATE : mDFF GENERIC MAP(CPU_CONTROLLER_STATE_WIDTH) PORT MAP(clk, rstn, nxt_state, cur_state);
	-- Next state logic
	NXT_DIR_STATE : PROCESS (
		clk, rstn, cur_state, cpu_dir, target_dir
	)
	BEGIN
		CASE cur_state IS
			WHEN IDLE => SW_LEFT <= '0'; SW_RIGHT <= '0';
				IF cpu_dir /= target_dir THEN nxt_state1 <= ROTATING;
				ELSE nxt_state1 <= IDLE;
				END IF;
			WHEN ROTATING =>
				IF cpu_dir = target_dir THEN nxt_state1 <= IDLE;
				ELSE
					IF (cpu_dir - target_dir) MOD 8 < 4 THEN SW_LEFT <= '0'; SW_RIGHT <= '1';
					ELSE SW_LEFT <= '1'; SW_RIGHT <= '0';
					END IF;
					nxt_state1 <= ROTATING;
				END IF;
			WHEN OTHERS => SW_LEFT <= '0'; SW_RIGHT <= '0'; nxt_state1 <= IDLE;
		END CASE;
	END PROCESS;
	nxt_state <= IDLE WHEN rstn='0' ELSE nxt_state1;

END impl;
