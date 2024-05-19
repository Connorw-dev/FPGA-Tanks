LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE wORk.declarations.ALL;

ENTITY mDFF IS
    GENERIC( n: INTEGER := 1 );
    PORT( clk, rstn: IN STD_LOGIC;
          D: IN STD_LOGIC_VECTOR( n-1 DOWNTO 0 );
          Q: OUT STD_LOGIC_VECTOR( n-1 DOWNTO 0 ) );
END mDFF;

ARCHITECTURE impl OF mDFF IS
BEGIN
	PROCESS(clk, rstn) BEGIN
		IF rstn ='0' then
			Q <= (OTHERS => '0');
		ELSIF rISINg_edge(clk) then
			Q <= D;
		END IF;
	END PROCESS;
END impl;