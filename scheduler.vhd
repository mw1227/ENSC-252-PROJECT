library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scheduler is
    generic ( N_FLOORS : integer := 8 );
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        current_floor : in  integer range 0 to N_FLOORS-1;
        pending_reqs  : in  std_logic_vector(N_FLOORS-1 downto 0);
        floor_inc     : out std_logic;
        floor_dec     : out std_logic;
        req_served    : out std_logic
    );
end scheduler;

architecture Behavioral of scheduler is

    type state_t is (IDLE, MOVING_UP, MOVING_DOWN, SERVING);
    signal state, next_state : state_t;
    signal any_req : std_logic;

begin

    any_req <= '1' when pending_reqs /= (others => '0') else '0';

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, pending_reqs, current_floor, any_req)
        variable min_distance  : integer;
        variable nearest_floor : integer;
    begin
        next_state <= state;

        case state is
            when IDLE =>
                if any_req = '1' then
                    if pending_reqs(current_floor) = '1' then
                        next_state <= SERVING;
                    else
                        min_distance  := N_FLOORS;
                        nearest_floor := current_floor;
                        for i in 0 to N_FLOORS-1 loop
                            if pending_reqs(i) = '1' then
                                if abs(current_floor - i) < min_distance then
                                    min_distance := abs(current_floor - i);
                                    nearest_floor := i;
                                end if;
                            end if;
                        end loop;

                        if nearest_floor > current_floor then
                            next_state <= MOVING_UP;
                        elsif nearest_floor < current_floor then
                            next_state <= MOVING_DOWN;
                        end if;
                    end if;
                end if;

            when MOVING_UP =>
                if pending_reqs(current_floor) = '1' then
                    next_state <= SERVING;
                elsif current_floor = N_FLOORS - 1 then
                    next_state <= MOVING_DOWN;
                end if;

            when MOVING_DOWN =>
                if pending_reqs(current_floor) = '1' then
                    next_state <= SERVING;
                elsif current_floor = 0 then
                    next_state <= MOVING_UP;
                end if;

            when SERVING =>
                if any_req = '0' then
                    next_state <= IDLE;
                elsif pending_reqs(current_floor) = '0' then
                    if current_floor < N_FLOORS-1 and pending_reqs(current_floor+1) = '1' then
                        next_state <= MOVING_UP;
                    elsif current_floor > 0 and pending_reqs(current_floor-1) = '1' then
                        next_state <= MOVING_DOWN;
                    else
                        next_state <= IDLE;
                    end if;
                end if;
        end case;
    end process;

    process(state)
    begin
        floor_inc  <= '0';
        floor_dec  <= '0';
        req_served <= '0';

        case state is
            when IDLE =>
                null;
            when MOVING_UP =>
                floor_inc <= '1';
            when MOVING_DOWN =>
                floor_dec <= '1';
            when SERVING =>
                req_served <= '1';
        end case;
    end process;

end Behavioral;
