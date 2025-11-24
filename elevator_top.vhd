library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity elevator_top is
    Port (
        CLOCK_50 : in  STD_LOGIC;
        SW       : in  STD_LOGIC_VECTOR(7 downto 0);
        KEY      : in  STD_LOGIC_VECTOR(3 downto 0);
        HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
        LEDR     : out STD_LOGIC_VECTOR(9 downto 0)
    );
end elevator_top;

architecture Structural of elevator_top is

    signal tick_1hz      : std_logic;
    signal wire_floor    : std_logic_vector(2 downto 0);
    signal wire_state    : std_logic_vector(2 downto 0);
    
    component clk_div
        Port ( clk_50 : in STD_LOGIC; reset_n : in STD_LOGIC; tick_1hz : out STD_LOGIC );
    end component;
    
    component controller_fsm
        Generic ( FLOORS, TRAVEL_TIME, ARRIVAL_WAIT_TIME, DOOR_OPEN_TIME : integer );
        Port (
            clk, tick : in STD_LOGIC;
            rst_hard_n, rst_soft_n, estop_n : in STD_LOGIC;
            req_sw : in STD_LOGIC_VECTOR(7 downto 0);
            floor_count : out STD_LOGIC_VECTOR(2 downto 0);
            state_code  : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;
    
    component display_driver
        Port (
            floor_in   : in  STD_LOGIC_VECTOR(2 downto 0);
            state_in   : in  STD_LOGIC_VECTOR(2 downto 0);
            led_dir    : out STD_LOGIC_VECTOR(2 downto 0);
            led_estop  : out STD_LOGIC;
            hex_floor  : out STD_LOGIC_VECTOR(6 downto 0);
            hex_door   : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

begin

    U_CLK : clk_div
    port map (
        clk_50   => CLOCK_50,
        reset_n  => KEY(2),
        tick_1hz => tick_1hz
    );

    U_CTRL : controller_fsm
    generic map (
        FLOORS => 8,
        TRAVEL_TIME => 2,
        ARRIVAL_WAIT_TIME => 2,
        DOOR_OPEN_TIME => 2
    )
    port map (
        clk         => CLOCK_50,
        tick        => tick_1hz,
        rst_hard_n  => KEY(2),
        rst_soft_n  => KEY(1),
        estop_n     => KEY(3),
        req_sw      => SW(7 downto 0),
        floor_count => wire_floor,
        state_code  => wire_state
    );
    
    U_DISP : display_driver
    port map (
        floor_in   => wire_floor,
        state_in   => wire_state,
        led_dir    => LEDR(2 downto 0),
        led_estop  => LEDR(9),
        hex_floor  => HEX0,
        hex_door   => HEX1
    );

    LEDR(8 downto 3) <= (others => '0');

end Structural;