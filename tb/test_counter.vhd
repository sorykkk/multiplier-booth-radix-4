ENTITY tb_counter IS
END tb_counter;

ARCHITECTURE test OF tb_counter IS

    CONSTANT WIDTH : INTEGER := 4;

    SIGNAL clk    : BIT := '0';
    SIGNAL rst    : BIT := '1';
    SIGNAL ld     : BIT := '0';
    SIGNAL clr    : BIT := '0';
    SIGNAL output : BIT_VECTOR(WIDTH-1 DOWNTO 0);

BEGIN

    -- Instanțiere Counter
    UUT: ENTITY WORK.Counter
        GENERIC MAP (
            delay => 10 ns,
            WIDTH => WIDTH)
        PORT MAP (
            clk    => clk,
            rst    => rst,
            ld     => ld,
            clr    => clr,
            output => output
        );

    -- Generator de clock pentru 10 ns perioadă
    clk_process : PROCESS
    BEGIN
        FOR i IN 0 TO 19 LOOP  -- 20 toggles = 10 perioade de ceas
            clk <= '0';
            WAIT FOR 5 ns;
            clk <= '1';
            WAIT FOR 5 ns;
        END LOOP;
        WAIT;  -- oprește procesul
    END PROCESS;

    -- Stimuli
    stim : PROCESS
    BEGIN
        -- Reset asincron
        rst <= '0'; WAIT FOR 20 ns;
        rst <= '1'; WAIT FOR 10 ns;

        -- Incrementare câteva cicluri
        ld <= '1'; WAIT FOR 80 ns;
        ld <= '0';

        -- Clear sincron
        clr <= '1'; WAIT FOR 10 ns;
        clr <= '0';

        -- Mai incrementăm câteva cicluri
        ld <= '1'; WAIT FOR 40 ns;
        ld <= '0';

        -- Stop simulare
        REPORT "Simulation finished";
        WAIT;  -- blochează simularea
    END PROCESS;

END ARCHITECTURE;
