LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY SegDecoder IS
Port ( D : in std_logic_vector( 3 downto 0 );
 Y : out std_logic_vector( 6 downto 0 ) );

 END SegDecoder;
 ARCHITECTURE LogicFunction OF SegDecoder IS
 BEGIN
  process(D)
    begin
        case D is
            when "0000" =>
                Y <= "1000000"; -- Display 0
            when "0001" =>
                Y <= "1111001"; -- Display 1
            when "0010" =>
                Y <= "0100100"; -- Display 2
            when "0011" =>
                Y <= "0110000"; -- Display 3
            when "0100" =>
                Y <= "0011001"; -- Display 4
            when "0101" =>
                Y <= "0010010"; -- Display 5
            when "0110" =>
                Y <= "0000010"; -- Display 6
            when "0111" =>
                Y <= "1111000"; -- Display 7
            when "1000" =>
                Y <= "0000000"; -- Display 8
            when "1001" =>
					 Y <= "0011000"; -- Display 9
			   when "1010" =>
					 Y <= "0001000"; -- Display A
			   when "1011" =>
					 Y <= "0000011"; -- Display B
			   when "1100" =>
					 Y <= "0100111"; -- Display C
			   when "1101" =>
					 Y <= "0100001"; -- Display D
			   when "1110" =>
					 Y <= "0000110"; -- Display E
			   when "1111" =>
					 Y <= "0001110"; -- Display F
				when others =>
				    Y <= "1111111";
        end case;
    end process;

  END LogicFunction ;
  