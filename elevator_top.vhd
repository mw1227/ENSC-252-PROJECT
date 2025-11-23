library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_top is
    port(
        clk       : in  std_logic;
        sw        : in  std_logic_vector(7 downto 0);
        key       : in  std_logic_vector(3 downto 0);
        hex0      : out std_logic_vector(6 downto 0);
        hex1      : out std_logic_vector(6 downto 0);
        led_estop : out std_logic
    );
end elevator_top;

architecture Behavioral of elevator_top is

    signal hard_reset    : std_logic;
    signal soft_reset    : std_logic;
    signal estop         : std_logic;

    signal clk_1hz       : std_logic;
    signal current_floor : integer range 0 to 7;
    signal pending_reqs  : std_logic_vector(7 downto 0);
    signal floor_inc     : std_logic;
    signal floor_dec     : std_logic;
    signal req_served    : std_logic;
    signal scheduler_state : integer range 0 to 6;

begin

    hard_reset <= not key(3);
    soft_reset <= not key(2);
    estop      <= not key(1);

    prescaler_inst : entity work.preScaler
        port map (
            clk_in  => clk,
            reset   => hard_reset,
            clk_out => clk_1hz
        );

    floor_manager_inst : entity work.floor_manager
        generic map (N_FLOORS => 8)
        port map (
            clk           => clk_1hz,
            hard_reset    => hard_reset,
            soft_reset    => soft_reset,
            estop         => estop,
            floor_inc     => floor_inc,
            floor_dec     => floor_dec,
            req_served    => req_served,
            request_btns  => sw,
            current_floor => current_floor,
            pending_reqs  => pending_reqs
        );

    scheduler_inst : entity work.scheduler
        generic map (N_FLOORS => 8)
        port map (
            clk           => clk_1hz,
            reset         => hard_reset,
            current_floor => current_floor,
            pending_reqs  => pending_reqs,
            floor_inc     => floor_inc,
            floor_dec     => floor_dec,
            req_served    => req_served,
            state_out     => scheduler_state
        );

    display_driver_inst : entity work.display_driver
        port map (
            clk       => clk_1hz,
            reset     => hard_reset,
            floor_in  => current_floor,
            state     => scheduler_state,
            hex_floor => hex0,
            hex_door  => hex1,
            estop_led => led_estop
        );

end Behavioral;
