library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity floor_manager is
    generic (
        N_FLOORS : integer := 8
    );
    port (
        clk           : in std_logic;
        hard_reset    : in std_logic;
        soft_reset    : in std_logic;
        estop         : in std_logic;
        floor_inc     : in std_logic;
        floor_dec     : in std_logic;
        req_served    : in std_logic;
        request_btns  : in std_logic_vector(N_FLOORS-1 downto 0);
        current_floor : out integer range 0 to N_FLOORS-1;
        pending_reqs  : out std_logic_vector(N_FLOORS-1 downto 0)
    );
end floor_manager;

architecture Behavioral of floor_manager is
    signal r_floor_index : integer range 0 to N_FLOORS-1 := 0;
    signal r_req_vector  : std_logic_vector(N_FLOORS-1 downto 0) := (others => '0');
    signal move_timer    : integer := 0;
    signal door_timer    : integer := 0;
    constant MOVE_DELAY  : integer := 2;
    constant DOOR_DELAY  : integer := 2;
    signal req_served_delayed: std_logic := '0';
begin

    p_floor_counter : process(clk, hard_reset)
    begin
        if hard_reset = '1' then
            r_floor_index <= 0;
            move_timer    <= 0;
        elsif rising_edge(clk) then
            if estop = '0' then
                if floor_inc = '1' or floor_dec = '1' then
                    move_timer <= move_timer + 1;
                    if move_timer >= MOVE_DELAY then
                        if floor_inc = '1' and r_floor_index < N_FLOORS-1 then
                            r_floor_index <= r_floor_index + 1;
                        elsif floor_dec = '1' and r_floor_index > 0 then
                            r_floor_index <= r_floor_index - 1;
                        end if;
                        move_timer <= 0;
                    end if;
                else
                    move_timer <= 0;
                end if;
            end if;
        end if;
    end process;

    p_request_latch : process(clk, hard_reset)
    begin
        if hard_reset = '1' then
            r_req_vector <= (others => '0');
            door_timer   <= 0;
            req_served_delayed <= '0';
        elsif rising_edge(clk) then
            if soft_reset = '1' then
                r_req_vector <= (others => '0');
                door_timer   <= 0;
            else
                for i in 0 to N_FLOORS-1 loop
                    if request_btns(i) = '1' then
                        r_req_vector(i) <= '1';
                    end if;
                end loop;

                if req_served = '1' then
                    if door_timer < DOOR_DELAY then
                        door_timer <= door_timer + 1;
                        req_served_delayed <= '0';
                    else
                        r_req_vector(r_floor_index) <= '0';
                        door_timer <= 0;
                        req_served_delayed <= '1';
                    end if;
                else
                    door_timer <= 0;
                    req_served_delayed <= '0';
                end if;
            end if;
        end if;
    end process;

    current_floor <= r_floor_index;
    pending_reqs  <= r_req_vector;

end Behavioral;
