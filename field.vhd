LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

ENTITY field IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        xscan, yscan : IN INTEGER;
        flag : OUT STD_LOGIC
    );
END field;

ARCHITECTURE behaviOR OF field IS
    CONSTANT y_max : INTEGER := 480;
    CONSTANT x_max : INTEGER := 640;
BEGIN
    -- Field IS drawn by settINg the flag based on specIFic coORdINates
    draw_field : PROCESS (clk, rstn)
    BEGIN
        IF rstn = '0' THEN
            flag <= '0';
        ELSIF rISINg_edge(clk) THEN
            -- Default IS not a wALL
            flag <= '0';

            -- Left bORder wALL
            IF (xscan >= 0 AND xscan <= 30 AND yscan >= 0 AND yscan <= y_max) THEN
                flag <= '1';
            -- Top bORder wALL
            ELSIF (xscan >= 0 AND xscan <= x_max AND yscan >= 0 AND yscan <= 30) THEN
                flag <= '1';
            -- Right bORder wALL
            ELSIF (xscan >= x_max-30 AND xscan <= x_max AND yscan >= 0 AND yscan <= y_max) THEN
                flag <= '1';
            -- Bottom bORder wALL
            ELSIF (xscan >= 0 AND xscan <= x_max AND yscan >= y_max-30 AND yscan <= y_max) THEN
                flag <= '1';
            -- DefINe the first rectangle
            ELSIF (xscan > 150 AND xscan < 200 AND yscan <= y_max / 3 AND yscan >0) THEN
                flag <= '1';
            -- DefINe the second rectangle
            ELSIF (xscan > 150 AND xscan < 200 AND yscan >= y_max * 2 / 3 AND yscan <= y_max) THEN
                flag <= '1';
            -- DefINe the third rectangle
            ELSIF (xscan > 300 AND xscan < 350 AND yscan > 160 AND yscan < 320) THEN
                flag <= '1';
            END IF;
        END IF;
    END PROCESS;
END behaviOR;