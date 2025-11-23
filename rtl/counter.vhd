ENTITY Counter IS
    GENERIC (
        delay : TIME := 10 ns;
        WIDTH : INTEGER := 8
    );
    PORT (
        clk    : IN BIT;
        rst    : IN BIT;
        ld     : IN BIT;
        clr    : IN BIT;

        output : OUT BIT_VECTOR(WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behave OF Counter is
    SIGNAL out_reg : BIT_VECTOR(WIDTH-1 DOWNTO 0);
BEGIN

    PROCESS (clk, rst) 
        VARIABLE carry: BIT;
    BEGIN
        IF rst = '0' THEN
            out_reg <= (others  => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF clr = '1' THEN
                out_reg <= (others => '0');

            ELSIF ld = '1' THEN
                carry := '1';
                FOR i IN 0 TO WIDTH-1 LOOP
                    out_reg(i) <= out_reg(i) XOR carry;
                    carry := out_reg(i) AND carry;
                END LOOP;
            END IF;
        END IF;

        output <= out_reg AFTER delay;
    END PROCESS;
    
END ARCHITECTURE behave;