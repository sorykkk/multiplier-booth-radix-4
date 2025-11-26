ENTITY reg_q IS
    GENERIC (
        delay : TIME := 10 ns;
        width : INTEGER := 32
    );
    PORT (
        clk      : IN  BIT;
        rst_b    : IN  BIT;
        ld_ibus  : IN  BIT;
        ld_obus  : IN  BIT;
        sh_r     : IN  BIT;
        sh_i     : IN  BIT_VECTOR(1 DOWNTO 0);
        ibus     : IN  BIT_VECTOR(width-1 DOWNTO 0);
        obus     : OUT BIT_VECTOR(width-1 DOWNTO 0);
        q        : OUT BIT_VECTOR(width DOWNTO 0)
    );
END ENTITY reg_q;

ARCHITECTURE rtl OF reg_q IS
    SIGNAL q_reg : BIT_VECTOR(width DOWNTO 0);
BEGIN
    -- logica secventiala pentru registrul q
    PROCESS(clk, rst_b)
    BEGIN
        IF rst_b = '0' THEN
            q_reg <= (OTHERS => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF ld_ibus = '1' THEN
                q_reg(width DOWNTO 1) <= ibus;
            ELSIF sh_r = '1' THEN
                q_reg <= sh_i & q_reg(width DOWNTO 2);
            END IF;
        END IF;
    END PROCESS;
    
    -- logica combinationala pentru output bus
    -- obus <= q_reg(width DOWNTO 1) WHEN ld_obus = '1' ELSE (OTHERS => '0') AFTER delay;
    obus <= q_reg(width DOWNTO 1) AFTER delay WHEN ld_obus = '1';
    q <= q_reg AFTER delay;
END ARCHITECTURE rtl;