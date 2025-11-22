library ieee;
use ieee.std_logic_1164.all;

entity display_driver is
    port (
        floor_in : in  integer range 0 to 3;
        hex_out  : out std_logic_vector(6 downto 0)
    );
end display_driver;

architecture Behavioral of display_driver is
begin
    -- Standard Active-Low 7-Segment Encoding
    -- 0 is mapped to display "1", 1 to "2", etc.
    process(floor_in)
    begin
        case floor_in is
            when 0 => hex_out <= "1111001"; -- Display '1'
            when 1 => hex_out <= "0100100"; -- Display '2'
            when 2 => hex_out <= "0110000"; -- Display '3'
            when 3 => hex_out <= "0011001"; -- Display '4'
            when others => hex_out <= "0111111"; -- Dash '-'
        end case;
    end process;
end Behavioral;