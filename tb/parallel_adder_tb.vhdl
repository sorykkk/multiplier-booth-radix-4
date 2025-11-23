ENTITY tb_parallel_adder IS
END ENTITY;

ARCHITECTURE sim OF tb_parallel_adder IS
	CONSTANT width : INTEGER := 4; -- valoare mica pentru a testa mai usor

	SIGNAL cin  : BIT;
	SIGNAL a    : BIT_VECTOR(width DOWNTO 0);
	SIGNAL b    : BIT_VECTOR(width DOWNTO 0);
	SIGNAL sum  : BIT_VECTOR(width DOWNTO 0);
	SIGNAL cout : BIT;	
BEGIN
	-- instantiam DUT
	uut : ENTITY work.parallel_adder
		GENERIC MAP (
			width => width,
			delay => 0 ns
		)
		PORT MAP (
			cin  => cin,
			a    => a,
			b    => b,
			sum  => sum,
			cout => cout
		);

	stim_proc : PROCESS 
	BEGIN
		-- TEST 1: 00001 + 00001 = 00010
		a <= "00001";
		b <= "00001";
		cin <= '0';
		WAIT FOR 10 ns;

		REPORT "TEST 1: a=00001 b=00001 cin=0 -> sum=" & sum & 
               " cout=" & cout;

		-- TEST 2: 00001 + 00001 + cin=1 = 00011
		a <= "00001";
		b <= "00001";
		cin <= '1';
		WAIT FOR 10 ns;

		REPORT "TEST 2: a=00001 b=00001 cin=1 → sum=" & sum & 
               " cout=" & cout;
		
		-- TEST 3: overflow — all ones + all ones
		
	END PROCESS stim_proc

END ARCHITECTURE sim;