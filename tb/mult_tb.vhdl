ENTITY tb_mult IS
END ENTITY;

ARCHITECTURE sim OF tb_mult IS 
    CONSTANT width : INTEGER := 16;
    CONSTANT delay : TIME := 3 ns;

    CONSTANT clk_period : TIME := 100 ns;
    CONSTANT clk_cycles : INTEGER := 1000;
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
    CONSTANT X : BIT_VECTOR(width-1 DOWNTO 0) := "0000000000000111"; -- 7
    CONSTANT Y : BIT_VECTOR(width-1 DOWNTO 0) := "0000000000000101"; -- 5
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

    -- Incepem secventa de semnale: bgn = 0, apoi il setam dupa RST_PULSE
    bgn_seq: PROCESS
    BEGIN
        bgn <= '0';
        WAIT FOR rst_pulse;
        bgn <= '1';
        REPORT "Begin signal asserted at time " & TIME'IMAGE(NOW);
        WAIT;
    END PROCESS bgn_seq;
    
    -- Input bus sequence
    input_seq: PROCESS
    BEGIN
        ibusA <= (OTHERS => '0');
        ibusB <= (OTHERS => '0');
        WAIT FOR 200 ns;
        
        ibusA <= X;
        REPORT "Set ibusA = " & to_string(X) & " (101 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        ibusB <= Y;
        REPORT "Set ibusB = " & to_string(Y) & " (63 in decimal) at time " & TIME'IMAGE(NOW);
        WAIT FOR 200 ns;
        
        REPORT "Input sequence completed";
        WAIT;
    END PROCESS input_seq;
    
    -- Monitor output and status
    out_seq: PROCESS
    BEGIN
        WAIT FOR 10 ns;
        LOOP
            IF fin = '1' THEN
                REPORT "Multiplication finished at time " & TIME'IMAGE(NOW);
                REPORT "  obusA = " & to_string(obusA);
                REPORT "  obusB = " & to_string(obusB);
                EXIT;
            END IF;
            WAIT FOR 100 ns;
        END LOOP;
        WAIT;
    END PROCESS out_seq;

END ARCHITECTURE sim;