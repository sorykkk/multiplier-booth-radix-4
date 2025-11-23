ENTITY tb_ControlUnit IS
END ENTITY;

ARCHITECTURE behavior OF tb_ControlUnit IS
    COMPONENT ControlUnit
        GENERIC (
            delay : TIME := 10 ns
        );
        PORT (
            clk : IN BIT;
            rst : IN BIT;
            bgn : IN BIT;
            cnt : IN BIT;
            q_0 : IN BIT_VECTOR(2 DOWNTO 0);
            fin : OUT BIT;
            c0 : OUT BIT;
            c2 : OUT BIT;
            c3 : OUT BIT;
            c4 : OUT BIT;
            c5 : OUT BIT;
            c6 : OUT BIT;
            c7 : OUT BIT
            -- state_temp : OUT BIT_VECTOR(3 DOWNTO 0);
            -- next_state_temp : OUT BIT_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk : BIT := '0';
    SIGNAL rst : BIT := '0';
    SIGNAL bgn : BIT := '1';
    SIGNAL cnt : BIT := '0';
    SIGNAL q_0 : BIT_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL fin : BIT;
    SIGNAL c0, c2, c3, c4, c5, c6, c7 : BIT;
    -- SIGNAL state_temp : BIT_VECTOR(3 DOWNTO 0);
    -- SIGNAL next_state_temp : BIT_VECTOR(3 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    uut: ControlUnit
        GENERIC MAP(
            delay => 10 ns
        )
        PORT MAP (
            clk => clk,
            rst => rst,
            bgn => bgn,
            cnt => cnt,
            q_0 => q_0,
            fin => fin,
            c0 => c0,
            c2 => c2,
            c3 => c3,
            c4 => c4,
            c5 => c5,
            c6 => c6,
            c7 => c7
            -- state_temp => state_temp,
            -- next_state_temp => next_state_temp
        );


    clk_process : PROCESS
    BEGIN
        FOR i IN 1 TO 60 LOOP
            clk <= '0';
            WAIT FOR clk_period/2;
            clk <= '1';
            WAIT FOR clk_period/2;
        END LOOP;
        WAIT;  
    END PROCESS;

    stim_proc : PROCESS
    BEGIN

        rst <= '0';
        WAIT FOR 2*clk_period;
        rst <= '1';
        WAIT FOR clk_period;


        bgn <= '0';
        WAIT FOR clk_period;

        WAIT FOR clk_period;

        q_0 <= "000";
        cnt <= '0';
        WAIT FOR 3*clk_period;

        q_0 <= "001";
        WAIT FOR 3*clk_period;

        q_0 <= "010";
        WAIT FOR 3*clk_period;

        q_0 <= "011";
        WAIT FOR 3*clk_period;

        q_0 <= "100";
        WAIT FOR 3*clk_period;

        q_0 <= "101";
        WAIT FOR 3*clk_period;

        q_0 <= "110";
        WAIT FOR 3*clk_period;

        q_0 <= "111";
        WAIT FOR 3*clk_period;

        cnt <= '1';
        WAIT FOR 3*clk_period;

        cnt <= '0';
        WAIT FOR 3*clk_period;

        WAIT FOR 20*clk_period;
        
        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;