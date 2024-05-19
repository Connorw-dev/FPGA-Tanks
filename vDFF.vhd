LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE wORk.declarations.ALL;

ENTITY vDFF IS
    PORT (
        D, Clk, Ld, Clr, Rstn : IN STD_LOGIC;
        Q : OUT STD_LOGIC
    );
END vDFF;

ARCHITECTURE behaviOR OF vDFF IS

BEGIN

    PROCESS (Rstn, Clk)
    BEGIN
        IF (Rstn = '0') THEN --Asynchronous reset
            Q <= '1';
        ELSIF (Clk'EVENT AND Clk = '1') THEN
            IF (Clr = '1') THEN --Synchronous reset
                Q <= '0';
            ELSIF (Ld = '1') THEN --Load SIGNAL
                Q <= D;
            END IF;
        END IF;
    END PROCESS;

END behaviOR;

