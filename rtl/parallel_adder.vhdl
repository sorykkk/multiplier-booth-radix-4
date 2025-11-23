ENTITY parallel_adder IS
	GENERIC(
		delay : TIME := 10ns,
		width : INTEGER := 32
	);
	PORT(
		cin  : IN  BIT;
		a    : IN  BIT_VECTOR(width DOWNTO 0);
		b    : IN  BIT_VECTOR(width DOWNTO 0);
		sum  : OUT BIT_VECTOR(width DOWNTO 0;
		cout : OUT BIT
	);
END ENTITY parallel_adder;

ARCHITECTURE rtl OF parallel_adder IS 
BEGIN
	PROCESS(a, b, cin) IS
		VARIABLE result : BIT_VECTOR(width DOWNTO 0);
		VARIABLE carry  : BIT;
		VARIABLE i      : INTEGER;
	BEGIN
		result := (OTHERS => '0');
		carry := cin;

		FOR i IN 0 TO width LOOP
			result(i) := (a(i) XOR b(i)) XOR carry;
			carry := (a(i) and b(i)) OR (carry AND (a(i) XOR b(i)));
		END LOOP;
		
		sum <= result AFTER delay;
		cout <= carry AFTER delay;
	END PROCESS;
END ARCHITECTURE rtl;