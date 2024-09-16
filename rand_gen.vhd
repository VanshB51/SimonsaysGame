library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;  

entity rand_gen is
    port (
        clk : in std_logic;
        rst : in std_logic;
        PulseOut : out STD_LOGIC_VECTOR(2 DOWNTO 0):="001"
    );
end rand_gen; 

architecture Behavioral of rand_gen is
    signal lfsr_reg : STD_LOGIC_VECTOR(3 downto 0) := "1001"; -- Initial value
    type mem is array (0 to 5) of std_logic_vector(2 downto 0);
    signal main_array_reg : mem := (others => (others => '0'));
    signal i : integer range 0 to 5:=0 ;
    signal j : integer := 0;
begin

    process (clk, rst)
    begin
        if rst = '1' then
           lfsr_reg <= "1001"; -- Reset to initial value
			  j<= 0;
			  i<= 0;
          elsif rising_edge(clk) then

			  if i = 0 then
			  PulseOut <= main_array_reg(0);
			  elsif i= 1 then
			  PulseOut <= main_array_reg(1);
			  elsif i=2 then
			  PulseOut <= main_array_reg(2);
			  elsif i= 3 then
			  PulseOut <= main_array_reg(3);
			  elsif i= 4 then
			  PulseOut <= main_array_reg(4);
			  else
			  PulseOut <= main_array_reg(5);
			  end if;
			  i<= i+1;
			  end if;

			 
			
			if j = 0 then
            -- LFSR feedback logic (XOR of certain bits)
            lfsr_reg(3) <= lfsr_reg(0) xor lfsr_reg(1) xor lfsr_reg(2);
            lfsr_reg(2) <= lfsr_reg(3) xor lfsr_reg(0);
            lfsr_reg(1) <= lfsr_reg(2);
            lfsr_reg(0) <= lfsr_reg(1);
		
            case lfsr_reg is
                when "0000" => 
                    main_array_reg <= ("100","100","010","010","001","001");
                when "0001" => 
                    main_array_reg <= ("100","010","010","001","001","001");
                when "0010" => 
                    main_array_reg <= ("010","100","010","100","001","001");
                when "0011" => 
                    main_array_reg <= ("001","100","001","010","010","001");
                when "0100" => 
                    main_array_reg <= ("001","001","100","010","001","001");
                when "0101" => 
                    main_array_reg <= ("001","001","010","001","100","001");
                when "0110" => 
                    main_array_reg <= ("010","100","100","010","100","001");
                when "0111" => 
                    main_array_reg <= ("001","010","010","001","001","100");
                when "1000" => 
                    main_array_reg <= ("001","100","001","100","001","010");
                when "1001" => 
                    main_array_reg <= ("010","100","100","001","100","001");
                when others =>
                    main_array_reg <= ("100","010","010","001","001","001");
            end case;
				end if;
    end process;

end Behavioral;
