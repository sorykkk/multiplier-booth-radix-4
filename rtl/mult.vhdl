ENTITY mult IS
    GENERIC (
        delay : TIME := 10 ns;
        width : INTEGER := 32
    );
    PORT (
        clk   : IN  BIT;
        rst_b : IN  BIT;
        bgn   : IN  BIT;
        ibusA : IN  BIT_VECTOR(width-1 DOWNTO 0);
        ibusB : IN  BIT_VECTOR(width-1 DOWNTO 0);
        obusA : OUT BIT_VECTOR(width-1 DOWNTO 0);
        obusB : OUT BIT_VECTOR(width-1 DOWNTO 0);
        fin   : OUT BIT
    );
END ENTITY mult;

ARCHITECTURE rtl of mult IS 
    -- functie ajutatoare pentru log2 ceiling
    FUNCTION log2_ceil(n : INTEGER) RETURN INTEGER IS 
        VARIABLE result : INTEGER := 0;
        VARIABLE temp   : INTEGER := n;
    BEGIN 
        WHILE temp > 1 LOOP
            temp := temp / 2;
            result := result + 1;
        END LOOP;
        RETURN result;
    END FUNCTION;

    -- functie ajutatoare pentru a verifica daca toti bitii sunt 1
    FUNCTION all_ones(v : BIT_VECTOR) RETURN BIT IS
    BEGIN 
        FOR i IN v'RANGE LOOP
            IF v(i) = '0' THEN 
                RETURN '0';
            END IF;
        END LOOP;
        RETURN '1';
    END FUNCTION;

    CONSTANT cnt_width : INTEGER := log2_ceil(width/2);

    -- semnale interne
    SIGNAL A       : BIT_VECTOR(width DOWNTO 0);
    SIGNAL Q       : BIT_VECTOR(width+1 DOWNTO 0);
    SIGNAL M       : BIT_VECTOR(width-1 DOWNTO 0);
    SIGNAL INV     : BIT_VECTOR(width DOWNTO 0);
    SIGNAL sum     : BIT_VECTOR(width DOWNTO 0);
    SIGNAL cnt     : BIT_VECTOR(cnt_width-1 DOWNTO 0);
    SIGNAL cout    : BIT;

    -- semnale de control
    SIGNAL is_cnt  : BIT;
    SIGNAL c0, c1, c2, c3, c4, c5, c6, c7, c8 : BIT;
BEGIN
    -- genereaza INV: fie shift stanga M sau extinderea semn M, apoi XOR cu c3
    PROCESS(M, c3, c4)
        VARIABLE m_extended : BIT_VECTOR(width DOWNTO 0);
        VARIABLE inv_temp   : BIT_VECTOR(width DOWNTO 0);
        VARIABLE xor_mask   : BIT_VECTOR(width DOWNTO 0);
    BEGIN 
        -- cream m_extended
        IF c4 = '1' THEN 
            m_extended := M & '0'; -- left shift: {M, 1'b0}
        ELSE
            m_extended := M(width-1) & M; -- sign extended {M[width-1], M}
        END IF;

        -- cream masca xor bazat pe c3
        IF c3 = '1' THEN 
            xor_mask := (OTHERS => '1');
        ELSE 
            xor_mask := (OTHERS => '0');
        END IF;

        -- xor
        FOR i IN width DOWNTO 0 LOOP 
            inv_temp(i) := m_extended(i) XOR xor_mask(i);
        END LOOP;

        INV <= inv_temp AFTER delay;
    END PROCESS;

    -- verificam daca toti bitii sunt 1
    is_cnt <= all_ones(cnt) AFTER delay;

    -- instantiem parallel_adder
    adder_inst : ENTITY work.parallel_adder
        GENERIC MAP (
            delay => delay,
            width => width
        )
        PORT MAP (
            cin  => c3,
            a    => INV,
            b    => A,
            sum  => sum,
            cout => cout
        );
    
    -- instantiem reg_m
    m_reg : ENTITY work.reg_m
        GENERIC MAP (
            delay => delay,
            width => width
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            ld_ibus  => c0,
            ibus     => ibusA,
            m        => M
        );
    
    -- instantiem reg_a
    a_reg : ENTITY work.reg_a
        GENERIC MAP (
            delay => delay,
            width => width
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            clr      => c0,
            ld_obus  => c7,
            ld_sum   => c2,
            sh_r     => c5,
            sh_i     => A(width),
            sum      => sum,
            obus     => obusA,
            a        => A
        );
    
    -- instantiem reg_q
    q_reg : ENTITY work.reg_q
        GENERIC MAP (
            delay => delay,
            width => width
        )
        PORT MAP (
            clk      => clk,
            rst_b    => rst_b,
            ld_ibus  => c0,
            ld_obus  => c7,
            sh_r     => c5,
            sh_i     => A(1 DOWNTO 0),
            ibus     => ibusB,
            obus     => obusB,
            q        => Q
        );
    
    -- Instantiate counter
    cnt_inst : ENTITY work.Counter
        GENERIC MAP (
            delay => delay,
            WIDTH => cnt_width
        )
        PORT MAP (
            clk    => clk,
            rst  => rst_b,
            ld     => c6,
            clr    => c0,
            output => cnt
        );
    
    -- Instantiate control unit
    cntrl_inst : ENTITY work.ControlUnit
        GENERIC MAP (
            delay => delay
        )
        PORT MAP (
            clk   => clk,
            rst => rst_b,
            bgn   => bgn,
            c0    => c0,
            c2    => c2,
            c3    => c3,
            c4    => c4,
            c5    => c5,
            c6    => c6,
            c7    => c7,
            fin   => fin,
            q_0   => Q(2 DOWNTO 0),
            cnt   => is_cnt
        );
END ARCHITECTURE rtl;