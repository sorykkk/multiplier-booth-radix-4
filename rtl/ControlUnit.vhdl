ENTITY ControlUnit is
    GENERIC(
        delay: TIME := 10 ns
    );
    PORT (
        clk: IN BIT;
        rst: IN BIT;
        bgn: IN BIT;
        cnt: IN BIT;
        q_0: IN BIT_VECTOR(2 DOWNTO 0);
        fin: OUT BIT;
        c0:  OUT BIT;
        c2:  OUT BIT;
        c3:  OUT BIT;
        c4:  OUT BIT;
        c5:  OUT BIT;
        c6:  OUT BIT;
        c7:  OUT BIT
        -- state_temp: out BIT_VECTOR(3 DOWNTO 0);
        -- next_state_temp: out BIT_VECTOR(3 DOWNTO 0)
    );

END ENTITY;


ARCHITECTURE behave OF ControlUnit is
    TYPE state_e IS (
        START,
        S0,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        SC,
        S8,
        S9
    );

    ATTRIBUTE enum_encoding : STRING;
    ATTRIBUTE enum_encoding OF state_e : TYPE IS
        "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010";

    SIGNAL state, next_state : state_e;


    -- FUNCTION state_to_vector(s : state_e) RETURN BIT_VECTOR IS
    -- BEGIN
    --     CASE s IS
    --         WHEN START => RETURN "0000";
    --         WHEN S0    => RETURN "0001";
    --         WHEN S2    => RETURN "0010";
    --         WHEN S3    => RETURN "0011";
    --         WHEN S4    => RETURN "0100";
    --         WHEN S5    => RETURN "0101";
    --         WHEN S6    => RETURN "0110";
    --         WHEN S7    => RETURN "0111";
    --         WHEN SC    => RETURN "1000";
    --         WHEN S8    => RETURN "1001";
    --         WHEN S9    => RETURN "1010";
    --     END CASE;
    -- END FUNCTION;


begin

    PROCESS (clk, rst)
    BEGIN
        IF rst = '0' THEN
            state <= START; 
        ELSIF clk'EVENT AND clk = '1' THEN
            state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (state, bgn, q_0, cnt)
    BEGIN
        next_state <= START; 
        
        CASE state IS
            WHEN START =>
                IF bgn = '0' THEN
                    next_state <= START;
                ELSE 
                    next_state <= S0;
                END IF;
            
            WHEN S0 => 
                next_state <= SC;
            
            WHEN SC =>
                IF q_0 = "010" OR q_0 = "001" THEN
                    next_state <= S2;
                ELSIF q_0 = "101" OR q_0 = "110" THEN
                    next_state <= S3;
                ELSIF q_0 = "011" THEN
                    next_state <= S4;
                ELSIF q_0 = "100" THEN
                    next_state <= S5;
                ELSIF q_0 = "000" OR q_0 = "111" THEN
                    next_state <= S6;
                END IF;
            
            WHEN S2 =>  
                next_state <= S6;
            
            WHEN S3 => 
                next_state <= S6;
            
            WHEN S4 =>
                next_state <= S6;
            
            WHEN S5 =>
                next_state <= S6;
            
            WHEN S6 =>
                IF cnt = '0' THEN
                    next_state <= S7;
                ELSE 
                    next_state <= S8;
                END IF;
            
            WHEN S7 =>
                next_state <= SC;
            
            WHEN S8 => 
                next_state <= S9;
            
            WHEN S9 => 
                next_state <= START;
                
        END CASE;
    END PROCESS;


    PROCESS (clk, rst)
    BEGIN
        IF rst = '0' THEN
            c0  <= '0';
            c2  <= '0';
            c3  <= '0';
            c4  <= '0';
            c5  <= '0';
            c6  <= '0';
            c7  <= '0';
            fin <= '0';
        ELSIF clk'EVENT AND clk = '1' THEN
            c0  <= '0' AFTER delay;
            c2  <= '0' AFTER delay;
            c3  <= '0' AFTER delay;
            c4  <= '0' AFTER delay;
            c5  <= '0' AFTER delay;
            c6  <= '0' AFTER delay;
            c7  <= '0' AFTER delay;
            fin <= '0' AFTER delay;
            
            CASE next_state IS
                WHEN START => 
                    
                WHEN S0 =>
                    c0 <= '1' AFTER delay;
                    
                WHEN S2 =>
                    c2 <= '1' AFTER delay;
                
                WHEN S3 =>
                    c2 <= '1' AFTER delay;
                    c3 <= '1' AFTER delay;
                
                WHEN S4 =>
                    c2 <= '1' AFTER delay;
                    c4 <= '1' AFTER delay;
                
                WHEN S5 =>
                    c2 <= '1' AFTER delay;
                    c3 <= '1' AFTER delay;
                    c4 <= '1' AFTER delay;
                
                WHEN S6 =>
                    c5 <= '1' AFTER delay;
                
                WHEN S7 =>
                    c6 <= '1' AFTER delay;
                
                WHEN S8 => 
                    c7  <= '1' AFTER delay;
                    fin <= '1' AFTER delay;
                
                WHEN S9 =>
                    
                WHEN SC =>
                    
            END CASE;
        END IF;
    END PROCESS;

    -- state_temp <= state_to_vector(state);
    -- next_state_temp <= state_to_vector(next_state);
END ARCHITECTURE behave;