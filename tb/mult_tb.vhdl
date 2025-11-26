ENTITY tb_mult IS
END ENTITY;

ARCHITECTURE sim OF tb_mult IS 
    CONSTANT width : INTEGER := 16;
    CONSTANT delay : TIME := 3 ns;

    CONSTANT clk_period : TIME := 100 ns;
    CONSTANT clk_cycles : INTEGER := 400;
    CONSTANT rst_pulse  : TIME := 25 ns;

    -- semnale de test
    SIGNAL clk   : BIT := '0';
    SIGNAL rst_b : BIT := '0';
    SIGNAL bgn   : BIT := '0';
    SIGNAL fin   : BIT;
    SIGNAL ibusA : BIT_VECTOR(WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ibusB : BIT_VECTOR(WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL obusA : BIT_VECTOR(WIDTH-1 DOWNTO 0);
    SIGNAL obusB : BIT_VECTOR(WIDTH-1 DOWNTO 0);

    -- valorile de test
    CONSTANT X1 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000000000111"; -- 7
    CONSTANT Y1 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000000000101"; -- 5

    CONSTANT X2 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000000001001"; -- 9
    CONSTANT Y2 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000001101000"; -- 104

    CONSTANT X3 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000011011001"; -- 217
    CONSTANT Y3 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000010010111"; -- 151

    CONSTANT X4 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000011011001"; -- 217
    CONSTANT Y4 : BIT_VECTOR(width-1 DOWNTO 0) := "0000000110011000"; -- 408

    -- expected output: 0000 0000 0010 0011 (35)

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

    -- instantiem multiplicatorul
    mul_unit : ENTITY work.mult 
        GENERIC MAP (
            delay => delay,
            width => width
        )
        PORT MAP (
            clk    => clk,
            rst_b  => rst_b,
            bgn    => bgn,
            ibusA  => ibusA,
            ibusB  => ibusB,
            obusA  => obusA,
            obusB  => obusB,
            fin    => fin
        );
    
    -- generator de clock: se va schimba fiecare `clk_period`/2 pentru `clk_cycles` ori
    clk_gen: PROCESS 
        VARIABLE cycle_count : INTEGER := 0;
    BEGIN 
        WHILE cycle_count < clk_cycles * 2 LOOP
            clk <= NOT clk;
            WAIT FOR clk_period / 2;
            cycle_count := cycle_count + 1;
        END LOOP;
        REPORT "Clock generation completed after " & INTEGER'IMAGE(CLK_CYCLES) & " cycles";
        WAIT;
    END PROCESS clk_gen;

    -- Reset sequence: rst_b = 0, then pulse high after RST_PULSE
    rst_seq: PROCESS
    BEGIN
        rst_b <= '0';
        WAIT FOR rst_pulse;
        rst_b <= '1';
        REPORT "Reset released at time " & TIME'IMAGE(NOW);
        WAIT;
    END PROCESS rst_seq;

    -- Input bus sequence
    input_seq: PROCESS
    BEGIN
        -- Test 1
        ibusA <= (OTHERS => '0');
        ibusB <= (OTHERS => '0');
        WAIT FOR 200 ns;
        
        ibusA <= X1;
        REPORT "Set ibusA = " & to_string(X1) & " (7 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        ibusB <= Y1;
        REPORT "Set ibusB = " & to_string(Y1) & " (5 in decimal) at time " & TIME'IMAGE(NOW);

        bgn <= '1';
        WAIT FOR 100 ns;
        bgn <= '0';

        WAIT UNTIL fin = '1';
        WAIT FOR 200 ns;  -- Dam timp sa printeze output

        -- Test 2
        ibusA <= (OTHERS => '0');
        ibusB <= (OTHERS => '0');
        WAIT FOR 200 ns;
        
        ibusA <= X2;
        REPORT "Set ibusA = " & to_string(X2) & " (9 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        ibusB <= Y2;
        REPORT "Set ibusB = " & to_string(Y2) & " (104 in decimal) at time " & TIME'IMAGE(NOW);
        
        bgn <= '1';
        WAIT FOR 100 ns;  -- un ciclu clock
        bgn <= '0';

        WAIT UNTIL fin = '1';
        WAIT FOR 200 ns;  -- Dam timp sa printeze output

        -- Test 3
        ibusA <= (OTHERS => '0');
        ibusB <= (OTHERS => '0');
        WAIT FOR 200 ns;
        
        ibusA <= X3;
        REPORT "Set ibusA = " & to_string(X3) & " (217 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        ibusB <= Y3;
        REPORT "Set ibusB = " & to_string(Y3) & " (151 in decimal) at time " & TIME'IMAGE(NOW);
        bgn <= '1';
        WAIT FOR 100 ns;  -- One clock cycle
        bgn <= '0';

        WAIT UNTIL fin = '1';
        WAIT FOR 200 ns;  -- Dam timp sa printeze output

        -- Test 4
        ibusA <= (OTHERS => '0');
        ibusB <= (OTHERS => '0');
        WAIT FOR 200 ns;
        
        ibusA <= X4;
        REPORT "Set ibusA = " & to_string(X4) & " (217 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        ibusB <= Y4;
        REPORT "Set ibusB = " & to_string(Y4) & " (408 in decimal) at time " & TIME'IMAGE(NOW);
        bgn <= '1';
        WAIT FOR 100 ns;  -- One clock cycle
        bgn <= '0';

        WAIT UNTIL fin = '1';
        WAIT FOR 200 ns;  -- Dam timp sa printeze output


        
        REPORT "Input sequence completed";
        WAIT;
    END PROCESS input_seq;
    
    -- Monitor output si status
    out_seq: PROCESS
    BEGIN
        WAIT FOR 10 ns;
        LOOP
            WAIT UNTIL fin = '1';  -- Wait for fin to go high
            REPORT "Multiplication finished at time " & TIME'IMAGE(NOW);
            REPORT "  obusA = " & to_string(obusA);
            REPORT "  obusB = " & to_string(obusB);
            WAIT UNTIL fin = '0';  -- Wait for fin to go low before next iteration
        END LOOP;
    END PROCESS out_seq;

END ARCHITECTURE sim;