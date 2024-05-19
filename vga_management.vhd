LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE wORk.declarations.ALL;

--COMPONENT USEd to manage the VGA synch SIGNALs (hs, vs) AND the scan SIGNALs on the screen (hpos, vpos)
ENTITY vga_management IS
    PORT (
        clk, rst : IN STD_LOGIC;
        hs, vs : OUT STD_LOGIC;
        hpos, vpos : BUFFER INTEGER
    );
END vga_management;

ARCHITECTURE behaviOR OF vga_management IS

BEGIN

    --HORizontal synch SIGNAL PROCESS
    hsynch : PROCESS (clk, rst)
    BEGIN
        IF (rst = '0') THEN
            hs <= '1';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (hpos > (hc + hd - 1) AND hpos <= (hc + hd + ha - 1)) THEN
                hs <= '0';
            ELSE
                hs <= '1';
            END IF;
        END IF;
    END PROCESS;

    --Vertical synch SIGNAL PROCESS
    vsynch : PROCESS (clk, rst)
    BEGIN
        IF (rst = '0') THEN
            vs <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (vpos > (vc + vd - 1) AND vpos <= (vc + vd + va - 1)) THEN
                vs <= '0';
            ELSE
                vs <= '1';
            END IF;
        END IF;
    END PROCESS;

    --HORizontal scan PROCESS
    hscan : PROCESS (clk, rst)
    BEGIN
        IF (rst = '0') THEN
            hpos <= 0;
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (hpos = (ha + hb + hc + hd - 1)) THEN
                hpos <= 0;
            ELSE
                hpos <= hpos + 1;
            END IF;
        END IF;
    END PROCESS;

    --Veritcal scan PROCESS
    vscan : PROCESS (clk, rst)
    BEGIN
        IF (rst = '0') THEN
            vpos <= 0;
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (vpos >= (va + vb + vc + vd - 1)) THEN
                vpos <= 0;
            ELSIF (hpos = ha + hb + hc + hd - 1) THEN
                vpos <= vpos + 1;
            END IF;
        END IF;
    END PROCESS;

END behaviOR;