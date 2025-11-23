ENTITY tb_registers IS
END ENTITY;

ARCHITECTURE sim OF tb_registers IS
    CONSTANT width : INTEGER := 4; -- luam un width mai mic (de 5 biti) pentru a fi mai testabil
    CONSTANT delay : TIME := 3 ns;
    -- Signale pentru reg_a
    SIGNAL clk       : BIT := '0';
    SIGNAL rst_b     : BIT := '0';
    SIGNAL clr_a     : BIT := '0';
    SIGNAL ld_obus_a : BIT := '0';
    SIGNAL ld_sum    : BIT := '0';
    SIGNAL sh_r_a    : BIT := '0';
    SIGNAL sh_i_a    : BIT := '0';
    SIGNAL sum       : BIT_VECTOR(width DOWNTO 0) := (OTHERS => '0');
    SIGNAL obus_a    : BIT_VECTOR(width-1 DOWNTO 0);
    SIGNAL a_out     : BIT_VECTOR(width DOWNTO 0);
    
    -- Signale pentru reg_q
    SIGNAL ld_ibus_q : BIT := '0';
    SIGNAL ld_obus_q : BIT := '0';
    SIGNAL sh_r_q    : BIT := '0';
    SIGNAL sh_i_q    : BIT_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ibus_q    : BIT_VECTOR(width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL obus_q    : BIT_VECTOR(width-1 DOWNTO 0);
    SIGNAL q_out     : BIT_VECTOR(width DOWNTO 0);
    
    -- Signale pentru reg_m
    SIGNAL ld_ibus_m : BIT := '0';
    SIGNAL ibus_m    : BIT_VECTOR(WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL m_out     : BIT_VECTOR(WIDTH-1 DOWNTO 0);

    -- functie ajutatoare pentru a converti din BIT_VECTOT in STRING
    FUNCTION to_string(bv : BIT_VECTOR) RETURN STRING IS
        VARIABLE result : STRING(1 TO bv'LENGTH);
        VARIABLE idx : INTEGER;
    BEGIN
        idx := 1;
        FOR i IN bv'RANGE LOOP
            IF bv(i) = '1' THEN
                result(idx) := '1';
            ELSE
                result(idx) := '0';
            END IF;
            idx := idx + 1;
        END LOOP;
        RETURN result;
    END FUNCTION;
BEGIN
    -- clock de perioada 20 ns
    clk <= NOT clk AFTER 10 ns;

    -- instantiem reg_a
    uut_a : ENTITY work.reg_a
        GENERIC MAP (
            width => width,
            delay => delay
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            clr      => clr_a,
            ld_obus  => ld_obus_a,
            ld_sum   => ld_sum,
            sh_r     => sh_r_a,
            sh_i     => sh_i_a,
            sum      => sum,
            obus     => obus_a,
            a        => a_out
        );
    
    -- instantiem reg_q
    uut_q : ENTITY work.reg_q
        GENERIC MAP (
            width => width,
            delay => delay
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            ld_ibus  => ld_ibus_q,
            ld_obus  => ld_obus_q,
            sh_r     => sh_r_q,
            sh_i     => sh_i_q,
            ibus     => ibus_q,
            obus     => obus_q,
            q        => q_out
        );

    -- instantiem reg_m
    uut_m : ENTITY work.reg_m
        GENERIC MAP (
            width => width,
            delay => delay
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            ld_ibus  => ld_ibus_m,
            ibus     => ibus_m,
            m        => m_out
        );

    -- stimuli
    stim_proc : PROCESS
    BEGIN
        REPORT "=== Testbench Start ===";

        -- Test 1: reset pentru toti registrii
        REPORT "TEST 1: Reset all registers";
        rst_b <= '0';
        WAIT FOR 20 ns;
        rst_b <= '1';
        WAIT FOR 20 ns;
        REPORT "  a=" & to_string(a_out) & " (should be 00000)";
        REPORT "  q=" & to_string(q_out) & " (should be 000000)";
        REPORT "  m=" & to_string(m_out) & " (should be 0000)";
        
        -- Test 2: incarcam reg_a cu valoarea 10101
        REPORT "TEST 2: Load reg_a with sum = 10101";
        sum <= "10101";
        ld_sum <= '1';
        WAIT FOR 20 ns;
        ld_sum <= '0';
        WAIT FOR 20 ns;
        REPORT "  a=" & to_string(a_out) & " (should be 10101)";
        
        -- Test 3: Right shift reg_a cu sh_i=1 (2 ori) si sh_i=0 (1 ori)
        REPORT "TEST 3: Shift right reg_a, sh_i=1 (3 times)";
        sh_i_a <= '1';
        sh_r_a <= '1';
        WAIT FOR 20 ns;
        REPORT "  After shift 1: a=" & to_string(a_out) & " (should be 11101)";
        WAIT FOR 20 ns;
        REPORT "  After shift 2: a=" & to_string(a_out) & " (should be 11111)";
        sh_i_a <= '0';
        WAIT FOR 20 ns;
        REPORT "  After shift 3: a=" & to_string(a_out) & " (should be 00111)";
        sh_r_a <= '0';
        WAIT FOR 20 ns;
        
        -- Test 4: incarcam reg_q
        REPORT "TEST 4: Load reg_q with ibus = 1010";
        ibus_q <= "1010";
        ld_ibus_q <= '1';
        WAIT FOR 20 ns;
        ld_ibus_q <= '0';
        WAIT FOR 20 ns;
        REPORT "  q=" & to_string(q_out) & " (should be 101000, lower bits = 1010)";
        
        -- Test 5: Right shift req_q cu sh_i=11 si sh_i=00
        REPORT "TEST 5: Shift right reg_q, sh_i=11 (2 times)"; --101000 -> 111010
        sh_i_q <= "11";
        sh_r_q <= '1';
        WAIT FOR 20 ns;
        REPORT "  After shift 1: q=" & to_string(q_out) & " (should be 11101)";
        sh_i_q <= "00";
        WAIT FOR 20 ns;
        REPORT "  After shift 2: q=" & to_string(q_out) & " (should be 00111)";
        sh_i_q <= "01";
        WAIT FOR 20 ns;
        REPORT "  After shift 2: q=" & to_string(q_out) & " (should be 01001)";
        sh_i_q <= "10";
        WAIT FOR 20 ns;
        REPORT "  After shift 2: q=" & to_string(q_out) & " (should be 10010)";
        sh_r_q <= '0';
        WAIT FOR 20 ns;
        
        -- Test 6: incarcam reg_m
        REPORT "TEST 6: Load reg_m with ibus = 1111";
        ibus_m <= "1111";
        ld_ibus_m <= '1';
        WAIT FOR 20 ns;
        ld_ibus_m <= '0';
        WAIT FOR 20 ns;
        REPORT "  m=" & to_string(m_out) & " (should be 1111)";
        
        -- Test 7: activeaza iesirea pentru reg_a
        REPORT "TEST 7: Output enable for reg_a";
        ld_obus_a <= '1';
        WAIT FOR 20 ns;
        REPORT "  obus_a=" & to_string(obus_a) & " (should be 0111)";
        ld_obus_a <= '0';
        WAIT FOR 20 ns;
        
        -- Test 8: activeaza iesirea pentru reg_q
        REPORT "TEST 8: Output enable for reg_q";
        ld_obus_q <= '1';
        WAIT FOR 20 ns;
        REPORT "  obus_q=" & to_string(obus_q) & " (should be 1001)";
        ld_obus_q <= '0';
        WAIT FOR 20 ns;
        
        -- Test 9: Clear reg_a
        REPORT "TEST 9: Clear reg_a";
        clr_a <= '1';
        WAIT FOR 20 ns;
        clr_a <= '0';
        WAIT FOR 20 ns;
        REPORT "  a=" & to_string(a_out) & " (should be 00000)";
        
        REPORT "=== Testbench Complete ===";
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE sim;