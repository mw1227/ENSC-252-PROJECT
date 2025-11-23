library ieee;
use ieee.std_logic_1164.all;

entity display_driver is
    port (
        floor_in   : in  integer range 0 to 7;
        door_open  : in  std_logic;
        state_desc : in  std_logic_vector(1 downto 0); -- 00:Idle, 01:Up, 10:Down
        estop      : in  std_logic;
        
        hex_floor  : out std_logic_vector(6 downto 0);
        hex_door   : out std_logic_vector(6 downto 0);
        led_dir    : out std_logic_vector(2 downto 0); -- [2]Up, [1]Down, [0]Idle
        led_estop  : out std_logic
    );
end display_driver;

architecture Behavioral of display_driver is
begin
    -- HEX 0: Floor
    process(floor_in, estop)
    begin
        if estop = '1' then
            hex_floor <= "0111111"; -- Dash
        else
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
        end if;
    end process;

    -- HEX 1: Door
    process(door_open, estop)
    begin
        if estop = '1' then
            hex_door <= "0111111"; -- Dash
        elsif door_open = '1' then
            hex_door <= "1000000"; -- 'O'
        else
            hex_door <= "0110001"; -- 'C'
        end if;
    end process;

    -- LEDs
    led_estop <= estop; -- LED on if ESTOP on
    
    process(state_desc, estop)
    begin
        led_dir <= "000";
        if estop = '0' then
            case state_desc is
                when "01" => led_dir <= "100"; -- UP
                when "10" => led_dir <= "010"; -- DOWN
                when others => led_dir <= "001"; -- IDLE
            end case;
        end if;
    end process;

end Behavioral;