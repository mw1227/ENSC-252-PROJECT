library ieee;
use ieee.std_logic_1164.all;

entity display_driver is
    port (
        floor_in  : in  integer range 0 to 7;  -- 8 floors
        door_open : in  std_logic;            -- door state
        hex_floor : out std_logic_vector(6 downto 0); -- for hex0
        hex_door  : out std_logic_vector(6 downto 0) -- for hex1
    );
end display_driver;

architecture Behavioral of display_driver is
begin
    process(floor_in)
    begin
        case floor_in is
            when 0 => hex_floor <= "1111001"; -- '1'
            when 1 => hex_floor <= "0100100"; -- '2'
            when 2 => hex_floor <= "0110000"; -- '3'
            when 3 => hex_floor <= "0011001"; -- '4'
            when 4 => hex_floor <= "0010010"; -- '5'
            when 5 => hex_floor <= "0000010"; -- '6'
            when 6 => hex_floor <= "1111000"; -- '7'
            when 7 => hex_floor <= "0000000"; -- '8'
            when others => hex_floor <= "0111111"; -- '-'
        end case;
    end process;

    process(door_open)
    begin
        if door_open = '1' then
            hex_door <= "1000000"; -- 'O'
        else
            hex_door <= "0110001"; -- 'C'
        end if;
    end process;

end Behavioral;
