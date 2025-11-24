library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller_fsm is
    Generic (
        FLOORS            : integer := 8;
        TRAVEL_TIME       : integer := 2;
        ARRIVAL_WAIT_TIME : integer := 2;
        DOOR_OPEN_TIME    : integer := 2
    );
    Port (
        clk         : in  STD_LOGIC;
        tick        : in  STD_LOGIC;
        rst_hard_n  : in  STD_LOGIC;
        rst_soft_n  : in  STD_LOGIC;
        estop_n     : in  STD_LOGIC;
        req_sw      : in  STD_LOGIC_VECTOR(FLOORS-1 downto 0);
        floor_count : out STD_LOGIC_VECTOR(2 downto 0);
        state_code  : out STD_LOGIC_VECTOR(2 downto 0)
    );
end controller_fsm;

architecture Behavioral of controller_fsm is

    type state_type is (
        INITIAL,
        IDLE,
        MOVE_UP,
        MOVE_DOWN,
        ARRIVE,
        DOOR_OPEN,
        DOOR_CLOSE,
        ESTOP
    );
    
    signal state_reg, state_next : state_type;

    signal current_floor_reg : integer range 0 to 7 := 0;
    signal timer_count       : integer := 0;
    signal direction         : std_logic_vector(1 downto 0) := "00"; 

    signal req_latched       : std_logic_vector(FLOORS-1 downto 0) := (others => '0');
    signal debounce_cnt      : integer range 0 to 500000 := 0;
    signal sw_sampled        : std_logic_vector(FLOORS-1 downto 0) := (others => '0');
    signal sw_prev           : std_logic_vector(FLOORS-1 downto 0) := (others => '0');

    signal req_above         : std_logic;
    signal req_below         : std_logic;
    signal req_here          : std_logic;
    
    signal travel_done       : boolean;
    signal arrive_done       : boolean;
    signal open_done         : boolean;

begin

    floor_count <= std_logic_vector(to_unsigned(current_floor_reg, 3));

    process(state_reg)
    begin
        case state_reg is
            when INITIAL    => state_code <= "000";
            when IDLE       => state_code <= "001";
            when MOVE_UP    => state_code <= "010";
            when MOVE_DOWN  => state_code <= "011";
            when ARRIVE     => state_code <= "100";
            when DOOR_OPEN  => state_code <= "101";
            when DOOR_CLOSE => state_code <= "110";
            when ESTOP      => state_code <= "111";
        end case;
    end process;

    process(req_latched, current_floor_reg)
        variable v_above : boolean := false;
        variable v_below : boolean := false;
    begin
        v_above := false;
        v_below := false;
        
        for i in 0 to FLOORS-1 loop
            if req_latched(i) = '1' then
                if i > current_floor_reg then v_above := true; end if;
                if i < current_floor_reg then v_below := true; end if;
            end if;
        end loop;

        if v_above then req_above <= '1'; else req_above <= '0'; end if;
        if v_below then req_below <= '1'; else req_below <= '0'; end if;
        req_here <= req_latched(current_floor_reg);
    end process;

    travel_done <= (timer_count >= TRAVEL_TIME - 1);
    arrive_done <= (timer_count >= ARRIVAL_WAIT_TIME - 1);
    open_done   <= (timer_count >= DOOR_OPEN_TIME - 1);

    process(clk, rst_hard_n)
    begin
        if rst_hard_n = '0' then
            state_reg <= INITIAL;
        elsif rising_edge(clk) then
            if estop_n = '0' then
                state_reg <= ESTOP;
            else
                state_reg <= state_next;
            end if;
        end if;
    end process;

    process(state_reg, req_here, req_above, req_below, direction, 
            travel_done, arrive_done, open_done, tick, rst_soft_n, current_floor_reg)
    begin
        state_next <= state_reg;

        case state_reg is
            when INITIAL =>
                state_next <= IDLE;

            when IDLE =>
                if req_here = '1' then
                    state_next <= ARRIVE;
                elsif req_above = '1' then
                    state_next <= MOVE_UP;
                elsif req_below = '1' then
                    state_next <= MOVE_DOWN;
                end if;

            when MOVE_UP =>
                if tick = '1' and travel_done then
                    state_next <= DOOR_CLOSE; 
                end if;

            when MOVE_DOWN =>
                if tick = '1' and travel_done then
                     state_next <= DOOR_CLOSE; 
                end if;

            when ARRIVE =>
                if tick = '1' and arrive_done then
                    state_next <= DOOR_OPEN;
                end if;

            when DOOR_OPEN =>
                if tick = '1' and open_done then
                    state_next <= DOOR_CLOSE;
                end if;

            when DOOR_CLOSE =>
                if req_here = '1' then
                    state_next <= ARRIVE;
                else
                    if direction = "01" then 
                        if req_above = '1' then state_next <= MOVE_UP;
                        elsif req_below = '1' then state_next <= MOVE_DOWN;
                        else state_next <= IDLE;
                        end if;
                    elsif direction = "10" then 
                        if req_below = '1' then state_next <= MOVE_DOWN;
                        elsif req_above = '1' then state_next <= MOVE_UP;
                        else state_next <= IDLE;
                        end if;
                    else
                        state_next <= IDLE;
                    end if;
                end if;

            when ESTOP =>
                if rst_soft_n = '0' then
                    state_next <= IDLE;
                end if;

            when others =>
                state_next <= IDLE;
        end case;
    end process;

    process(clk, rst_hard_n)
    begin
        if rst_hard_n = '0' then
            current_floor_reg <= 0;
            timer_count <= 0;
            direction <= "00";
            req_latched <= (others => '0');
            sw_sampled <= (others => '0');
            sw_prev <= (others => '0');
            debounce_cnt <= 0;
        elsif rising_edge(clk) then
            
            if debounce_cnt < 500000 then 
                debounce_cnt <= debounce_cnt + 1;
            else
                debounce_cnt <= 0;
                sw_sampled <= req_sw;
            end if;

            if rst_soft_n = '0' then
                req_latched <= (others => '0');
                sw_prev <= sw_sampled;
            else
                for i in 0 to FLOORS-1 loop
                    if (sw_sampled(i) = '1' and sw_prev(i) = '0') then
                        req_latched(i) <= '1';
                    end if;
                    if state_reg = DOOR_OPEN and current_floor_reg = i then
                        req_latched(i) <= '0';
                    end if;
                end loop;

                if debounce_cnt = 0 then
                    sw_prev <= sw_sampled;
                end if;
            end if;

            if state_reg /= state_next then
                timer_count <= 0;
            elsif tick = '1' then
                timer_count <= timer_count + 1;
            end if;

            if state_reg = MOVE_UP and tick = '1' and travel_done then
                if current_floor_reg < FLOORS-1 then
                    current_floor_reg <= current_floor_reg + 1;
                end if;
            elsif state_reg = MOVE_DOWN and tick = '1' and travel_done then
                if current_floor_reg > 0 then
                    current_floor_reg <= current_floor_reg - 1;
                end if;
            elsif state_reg = INITIAL then
                current_floor_reg <= 0;
            end if;

            if state_reg = IDLE then
                if req_above = '1' then direction <= "01";
                elsif req_below = '1' then direction <= "10";
                else direction <= "00";
                end if;
            elsif state_reg = DOOR_CLOSE then
                if req_here = '0' then
                    if direction = "01" and req_above = '0' and req_below = '1' then
                        direction <= "10";
                    elsif direction = "10" and req_below = '0' and req_above = '1' then
                        direction <= "01";
                    elsif req_above = '0' and req_below = '0' then
                        direction <= "00";
                    end if;
                end if;
            elsif state_reg = INITIAL then
                direction <= "00";
            end if;

        end if;
    end process;

end Behavioral;