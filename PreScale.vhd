LIBRARY ieee;
USE ieee.numeric_std.all; 
USE ieee.std_logic_1164.all;

entity PreScale is 
generic (dw : integer := 24);

	port (inCLOCK: in std_logic;
			outCLOCK: out std_logic); 
end Prescale; 


Architecture behaviour of PreScale is 

signal temp: unsigned (dw-1 downto 0):= (others=> '0'); 

Begin 
process (inCLOCK)

	BEGIN
		if (rising_edge(inCLOCK)) THEN
			temp <= temp+1;

		end if;
	END PROCESS;
outCLOCK <= temp(dw-1);
end behaviour; 