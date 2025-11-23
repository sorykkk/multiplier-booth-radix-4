ENTITY tb_parallel_adder IS
END ENTITY;

ARCHITECTURE sim OF tb_parallel_adder IS
    CONSTANT width : INTEGER := 4;	-- luam un width mai mic (de 5 biti) pentru a fi mai testabil
    SIGNAL cin  : BIT;
    SIGNAL a    : BIT_VECTOR(width DOWNTO 0);
    SIGNAL b    : BIT_VECTOR(width DOWNTO 0);
    SIGNAL sum  : BIT_VECTOR(width DOWNTO 0);
    SIGNAL cout : BIT;  
    
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
    
	-- functie ajutatoare pentru a converti din BIT in STRING
    FUNCTION bit_to_string(b : BIT) RETURN STRING IS
    BEGIN
        IF b = '1' THEN
            RETURN "1";
        ELSE
            RETURN "0";
        END IF;
    END FUNCTION;
    
BEGIN
    -- Instantiate DUT
    uut : ENTITY work.parallel_adder
        GENERIC MAP (
            width => width,
            delay => 3 ns
        )
        PORT MAP (
            cin  => cin,
            a    => a,
            b    => b,
            sum  => sum,
            cout => cout
        );
    
    -- Stimuli
    stim_proc : PROCESS 
    BEGIN
        -- TEST 1: 00001 + 00001 = 00010
        a <= "00001";
        b <= "00001";
        cin <= '0';
        WAIT FOR 10 ns;

        REPORT "TEST 1: a=" & to_string(a) &
               " b=" & to_string(b) &
               " cin=" & bit_to_string(cin) &
               " => sum=" & to_string(sum) &
               " cout=" & bit_to_string(cout);
        
        -- TEST 2: 00001 + 00001 + cin=1 = 00011
        a <= "00001";
        b <= "00001";
        cin <= '1';
        WAIT FOR 10 ns;

        REPORT "TEST 2: a=" & to_string(a) &
               " b=" & to_string(b) &
               " cin=" & bit_to_string(cin) &
               " => sum=" & to_string(sum) &
               " cout=" & bit_to_string(cout);
        
        -- TEST 3: overflow — all ones + all ones
        a   <= (OTHERS => '1');
        b   <= (OTHERS => '1');
        cin <= '0';
        WAIT FOR 10 ns;
		
        REPORT "TEST 3: a=" & to_string(a) &
               " b=" & to_string(b) &
               " cin=" & bit_to_string(cin) &
               " => sum=" & to_string(sum) &
               " cout=" & bit_to_string(cout);
        
        -- END SIMULATION
        REPORT "Simulation completed.";
        WAIT;
    END PROCESS stim_proc;
END ARCHITECTURE sim;