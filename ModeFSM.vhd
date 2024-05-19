LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
USE ieee.STD_LOGIC_mISc.ALL;
USE wORk.declarations.ALL;

ENTITY ModeFSM IS
	PORT(clk, rstn, END_game : IN STD_LOGIC;
	     SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	     mode : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END ModeFSM;

ARCHITECTURE impl OF ModeFSM IS
	SIGNAL cur_state : STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
	SIGNAL nxt_state, nxt_state1 : STD_LOGIC_VECTOR(MODE_STATE_WIDTH-1 DOWNTO 0);
BEGIN
	-- State regISter
	MODE_STATE : mDFF GENERIC MAP(MODE_STATE_WIDTH) PORT MAP(clk, rstn, nxt_state, cur_state);
	-- Next state logic
	PROCESS (clk, rstn, cur_state, SW, END_game) BEGIN
		CASE cur_state IS
			WHEN MAIN_MENU => mode <= MAIN_MENU;
				IF SW(0)='1' then nxt_state1 <= GAME_STATE; ELSE nxt_state1 <= MAIN_MENU; END IF;
			WHEN GAME_STATE => mode <= GAME_STATE;
				IF END_game='1' then nxt_state1 <= GAME_OVER_SCREEN; ELSE nxt_state1 <= GAME_STATE; END IF;
			WHEN GAME_OVER_SCREEN => mode <= GAME_OVER_SCREEN;
				IF SW(2)='1' then nxt_state1 <= MAIN_MENU; ELSE nxt_state1 <= GAME_OVER_SCREEN; END IF;
			WHEN OTHERS => mode <= MAIN_MENU;
		END CASE;
	END PROCESS;
	nxt_state <= MAIN_MENU WHEN rstn='0' ELSE nxt_state1;
END impl;