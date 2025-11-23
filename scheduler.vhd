library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scheduler is
    generic ( 
        N_FLOORS        : integer := 8;
        TICKS_PER_FLOOR : integer := 2; 
        TICKS_DOOR_OPEN : integer := 3 
    );
    port (
        clk           : in  std_logic; 
        reset         : in  std_logic;
        current_floor : in  integer range 0 to N_FLOORS-1;
        pending_reqs  : in  std_logic_vector(N_FLOORS-1 downto 0);
        
        floor_inc     : out std_logic;
        floor_dec     : out std_logic;
        req_served    : out std_logic;
        
        state_out     : out integer range 0 to 6;
        led_dir       : out std_logic_vector(2 downto 0) 
    );
end scheduler;

architecture Behavioral of scheduler is

    type state_t is (IDLE, MOVING_UP, MOVING_DOWN, SYNC_FLOOR, DOOR_OPEN, DOOR_CLOSE);
    signal state : state_t;
    
    signal timer : integer range 0 to 100 := 0;
    signal last_dir_up : boolean := true; 
    
    function check_reqs_above(reqs : std_logic_vector; curr : integer) return boolean is
    begin
        if curr >= N_FLOORS-1 then return false; end if;
        for i in curr+1 to N_FLOORS-1 loop
            if reqs(i) = '1' then return true; end if;
        end loop;
        return false;
    end function;

    function check_reqs_below(reqs : std_logic_vector; curr : integer) return boolean is
    begin
        if curr <= 0 then return false; end if;
        for i in 0 to curr-1 loop
            if reqs(i) = '1' then return true; end if;
        end loop;
        return false;
    end function;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            timer <= 0;
            floor_inc <= '0';
            floor_dec <= '0';
            req_served <= '0';
            last_dir_up <= true;
            
        elsif rising_edge(clk) then
            floor_inc <= '0';
            floor_dec <= '0';
            req_served <= '0';
            
            case state is

                when IDLE =>
                    timer <= 0;
                    
                    if pending_reqs(current_floor) = '1' then
                        state <= DOOR_OPEN;
                        
                    else 
                        if last_dir_up then
                            if check_reqs_above(pending_reqs, current_floor) then
                                state <= MOVING_UP;
                            elsif check_reqs_below(pending_reqs, current_floor) then
                                state <= MOVING_DOWN;
                                last_dir_up <= false;
                            end if;
                        else
                            if check_reqs_below(pending_reqs, current_floor) then
                                state <= MOVING_DOWN;
                            elsif check_reqs_above(pending_reqs, current_floor) then
                                state <= MOVING_UP;
                                last_dir_up <= true;
                            end if;
                        end if;
                    end if;


                when MOVING_UP =>
                    if timer < TICKS_PER_FLOOR then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        floor_inc <= '1'; 
                        state <= SYNC_FLOOR;
                    end if;


                when MOVING_DOWN =>
                    if timer < TICKS_PER_FLOOR then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        floor_dec <= '1'; 
                        state <= SYNC_FLOOR;
                    end if;

                when SYNC_FLOOR =>
                    if pending_reqs(current_floor) = '1' then
                        state <= DOOR_OPEN;
                    else
                        if last_dir_up then
                             if check_reqs_above(pending_reqs, current_floor) then
                                 state <= MOVING_UP;
                             elsif check_reqs_below(pending_reqs, current_floor) then
                                 state <= MOVING_DOWN;
                                 last_dir_up <= false;
                             else
                                 state <= IDLE;
                             end if;
                        else
                             if check_reqs_below(pending_reqs, current_floor) then
                                 state <= MOVING_DOWN;
                             elsif check_reqs_above(pending_reqs, current_floor) then
                                 state <= MOVING_UP;
                                 last_dir_up <= true;
                             else
                                 state <= IDLE;
                             end if;
                        end if;
                    end if;


                when DOOR_OPEN =>
                    if timer < TICKS_DOOR_OPEN then
                        timer <= timer + 1;
                    else
                        timer <= 0;
                        state <= DOOR_CLOSE;
                    end if;


                when DOOR_CLOSE =>
                    req_served <= '1'; 

                    if last_dir_up then
                        if check_reqs_above(pending_reqs, current_floor) then
                            state <= MOVING_UP;
                        elsif check_reqs_below(pending_reqs, current_floor) then
                            state <= MOVING_DOWN;
                            last_dir_up <= false;
                        else
                            state <= IDLE;
                        end if;
                    else
                         if check_reqs_below(pending_reqs, current_floor) then
                            state <= MOVING_DOWN;
                         elsif check_reqs_above(pending_reqs, current_floor) then
                            state <= MOVING_UP;
                            last_dir_up <= true;
                         else
                            state <= IDLE;
                         end if;
                    end if;
                    
            end case;
        end if;
    end process;

    process(state, last_dir_up)
    begin

        case state is
            when IDLE        => state_out <= 0;
            when MOVING_UP   => state_out <= 1;
            when MOVING_DOWN => state_out <= 2;
            when SYNC_FLOOR  => state_out <= 0; -- Transient state, show IDLE or prev dir
            when DOOR_OPEN   => state_out <= 5; 
            when DOOR_CLOSE  => state_out <= 6; 
            when others      => state_out <= 0;
        end case;

        if state = IDLE then
            led_dir <= "000"; -- Off or special IDLE pattern
        elsif state = MOVING_UP or (state /= MOVING_DOWN and last_dir_up) then
            led_dir <= "001"; -- UP LED
        else
            led_dir <= "010"; -- DOWN LED
        end if;
    end process;

end Behavioral;