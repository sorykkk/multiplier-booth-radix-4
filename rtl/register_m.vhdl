ENTITY reg_m IS
    GENERIC (
        delay : TIME := 10 ns;
        width : INTEGER := 32
    );
    PORT (
        clk      : IN  BIT;
        rst_b    : IN  BIT;
        ld_ibus  : IN  BIT;
        ibus     : IN  BIT_VECTOR(width-1 DOWNTO 0);
        m        : OUT BIT_VECTOR(width-1 DOWNTO 0)
    );
END ENTITY reg_m;

ARCHITECTURE rtl OF reg_m IS
    SIGNAL m_reg : BIT_VECTOR(width-1 DOWNTO 0);
BEGIN
    PROCESS(clk, rst_b)
    BEGIN
        IF rst_b = '0' THEN
            m_reg <= (OTHERS => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF ld_ibus = '1' THEN
                m_reg <= ibus;
            END IF;
        END IF;
    END PROCESS;
    
    m <= m_reg AFTER delay;
END ARCHITECTURE rtl;