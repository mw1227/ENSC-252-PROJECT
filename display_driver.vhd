library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_driver is
    Port (
        floor_in   : in  STD_LOGIC_VECTOR(2 downto 0);
        state_in   : in  STD_LOGIC_VECTOR(2 downto 0);
        led_dir    : out STD_LOGIC_VECTOR(2 downto 0);
        led_estop  : out STD_LOGIC;
        hex_floor  : out STD_LOGIC_VECTOR(6 downto 0);
        hex_door   : out STD_LOGIC_VECTOR(6 downto 0)
    );
end display_driver;

architecture Behavioral of display_driver is
begin

    process(state_in)
    begin
        led_estop <= '0';
        led_dir   <= "100";
        hex_door  <= "1000110";

        case state_in is
            when "010" =>
                led_dir <= "010";

            when "011" =>
                led_dir <= "001";

            when "101" =>
                hex_door <= "1000000";

            when "111" =>
                led_estop <= '1';

            when others =>
                null;
        end case;
    end process;

    process(floor_in)
    begin
        case floor_in is
            when "000" => hex_floor <= "1111001";
            when "001" => hex_floor <= "0100100";
            when "010" => hex_floor <= "0110000";
            when "011" => hex_floor <= "0011001";
            when "100" => hex_floor <= "0010010";
            when "101" => hex_floor <= "0000010";
            when "110" => hex_floor <= "1111000";
            when "111" => hex_floor <= "0000000";
            when others => hex_floor <= "1111111";
        end case;
    end process;

end Behavioral;