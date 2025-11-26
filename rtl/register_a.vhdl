ENTITY reg_a IS 
    GENERIC(
        delay : TIME := 10 ns;
        width : INTEGER := 32
    );
    PORT(
        clk     : IN  BIT;
        rst_b   : IN  BIT;
        clr     : IN  BIT;
        ld_obus : IN  BIT;
        ld_sum  : IN  BIT;
        sh_r    : IN  BIT;
        sh_i    : IN  BIT;
        sum     : IN  BIT_VECTOR(width DOWNTO 0);
        obus    : OUT BIT_VECTOR(width-1 DOWNTO 0);
        a       : OUT BIT_VECTOR(width DOWNTO 0)
    );
END ENTITY reg_a;

ARCHITECTURE rtl OF reg_a IS 
    SIGNAL a_reg : BIT_VECTOR(width DOWNTO 0);
BEGIN
    -- logica secventiala pentru registru a
    PROCESS(clk, rst_b)
    BEGIN
        IF rst_b = '0' OR clr = '1' THEN
            a_reg <= (OTHERS => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF sh_r = '1' THEN
                a_reg <= sh_i & sh_i & a_reg(width DOWNTO 2);
            ELSIF ld_sum = '1' THEN
                a_reg <= sum;
            END IF;
        END IF;
    END PROCESS;

    -- logica combinationala pentru output bus
    -- obus <= a_reg(width-1 DOWNTO 0) WHEN ld_obus = '1' ELSE (OTHERS => '0') AFTER delay;
    obus <= a_reg(width-1 downto 0) AFTER delay WHEN ld_obus = '1';
    a <= a_reg AFTER delay;
END ARCHITECTURE rtl;