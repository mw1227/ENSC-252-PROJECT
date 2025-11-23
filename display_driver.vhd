library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_driver_fsm is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        floor_in  : in  integer range 0 to 7;
        state     : in  integer range 0 to 6;
        hex_floor : out std_logic_vector(6 downto 0);
        hex_door  : out std_logic_vector(6 downto 0);
        estop_led : out std_logic
    );
end entity;

architecture Behavioral of display_driver_fsm is

    type state_t is (IDLE, MOVING_UP, MOVING_DOWN, SERVING, ESTOP, DOOR_OPEN, DOOR_CLOSE);

begin

    process(state, floor_in)
    begin
        hex_floor <= "0111111";
        hex_door  <= "0111111";
        estop_led <= '0';

        case state is
            when IDLE | MOVING_UP | MOVING_DOWN | DOOR_CLOSE =>
                estop_led <= '0';
                case floor_in is
                    when 0 => hex_floor <= "1111001";
                    when 1 => hex_floor <= "0100100";
                    when 2 => hex_floor <= "0110000";
                    when 3 => hex_floor <= "0011001";
                    when 4 => hex_floor <= "0010010";
                    when 5 => hex_floor <= "0000010";
                    when 6 => hex_floor <= "1111000";
                    when 7 => hex_floor <= "0000000";
                    when others => hex_floor <= "0111111";
                end case;
                hex_door <= "0110001"; 

            when SERVING | DOOR_OPEN =>
                estop_led <= '0';
                case floor_in is
                    when 0 => hex_floor <= "1111001";
                    when 1 => hex_floor <= "0100100";
                    when 2 => hex_floor <= "0110000";
                    when 3 => hex_floor <= "0011001";
                    when 4 => hex_floor <= "0010010";
                    when 5 => hex_floor <= "0000010";
                    when 6 => hex_floor <= "1111000";
                    when 7 => hex_floor <= "0000000";
                    when others => hex_floor <= "0111111";
                end case;
                hex_door <= "1000000"; 

            when ESTOP =>
                estop_led <= '1';
                hex_floor <= "0111111";
                hex_door  <= "0111111";

        end case;
    end process;

end architecture;
