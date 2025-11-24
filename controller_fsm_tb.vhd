library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_fsm_tb is
end controller_fsm_tb;

architecture sim of controller_fsm_tb is

    constant FLOORS : integer := 8;
    
    constant BUTTON_HOLD_TIME : time := 10 ms;
    
    constant TICK_PERIOD : time := 100 us; 

    signal clk         : std_logic := '0';
    signal tick        : std_logic := '0';
    signal rst_hard_n  : std_logic := '0';
    signal rst_soft_n  : std_logic := '1';
    signal estop_n     : std_logic := '1';
    signal req_sw      : std_logic_vector(FLOORS-1 downto 0) := (others => '0');
    signal floor_count : std_logic_vector(2 downto 0);
    signal state_code  : std_logic_vector(2 downto 0);

begin

    clk <= not clk after 10 ns; 

    tick_gen : process
    begin
        wait for TICK_PERIOD;
        wait until rising_edge(clk);
        tick <= '1';
        wait until rising_edge(clk);
        tick <= '0';
    end process;

    dut : entity work.controller_fsm
        generic map(
            FLOORS => FLOORS,
            TRAVEL_TIME => 2,       
            ARRIVAL_WAIT_TIME => 2, 
            DOOR_OPEN_TIME => 2     
        )
        port map(
            clk => clk,
            tick => tick,
            rst_hard_n => rst_hard_n,
            rst_soft_n => rst_soft_n,
            estop_n => estop_n,
            req_sw => req_sw,
            floor_count => floor_count,
            state_code => state_code
        );

        stim : process
    begin

        rst_hard_n <= '0';
        req_sw <= (others => '0');
        wait for BUTTON_HOLD_TIME; 

        rst_hard_n <= '1';
        wait for BUTTON_HOLD_TIME; 

        req_sw(5) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(5) <= '0';        
        wait for 3 ms;

        req_sw(7) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(7) <= '0';
        wait for 200 us;

        req_sw(2) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(2) <= '0';

        req_sw(6) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(6) <= '0';

        wait for 3 ms;

        req_sw(to_integer(unsigned(floor_count))) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(to_integer(unsigned(floor_count))) <= '0';

        wait for 1 ms;

        rst_hard_n <= '0';
        wait for BUTTON_HOLD_TIME;
        rst_hard_n <= '1';
        wait for 1 ms;

        req_sw(0) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(0) <= '0';

        wait for 2 ms;

        req_sw(7) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(7) <= '0';
        wait for 3 ms;

        req_sw(7) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(7) <= '0';

        wait for 2 ms;

        req_sw(3) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(3) <= '0';

        wait for 200 us;

        rst_hard_n <= '0';
        wait for 2 ms;
        rst_hard_n <= '1';
        wait for 2 ms;

        req_sw(1) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(1) <= '0';

        wait for 300 us;

        rst_soft_n <= '0';
        wait for BUTTON_HOLD_TIME;
        rst_soft_n <= '1';

        wait for 1 ms;

        req_sw(4) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(4) <= '0';

        wait for 300 us;

        req_sw(6) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw(6) <= '0';

        wait for 3 ms;

        estop_n <= '0';
        wait for BUTTON_HOLD_TIME;
        estop_n <= '1';

        wait for 1 ms;

        rst_soft_n <= '0';
        wait for 1 ms;
        rst_soft_n <= '1';

        req_sw(2) <= '1';
        req_sw(5) <= '1';
        req_sw(7) <= '1';
        wait for BUTTON_HOLD_TIME;
        req_sw <= (others => '0');

        wait for 10 ms;

        wait;
    end process;

end architecture;