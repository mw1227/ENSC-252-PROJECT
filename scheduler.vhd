library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scheduler is
    generic ( N_FLOORS : integer := 4 );
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
    type dir_t is (DIR_UP, DIR_DOWN);
    signal dir     : dir_t := DIR_UP;
    signal any_req : std_logic;
begin

    any_req <= '1' when pending_reqs /= (others => '0') else '0';

    process(current_floor, pending_reqs, dir, any_req)
    begin
        floor_inc  <= '0';
        floor_dec  <= '0';
        req_served <= '0';

        if any_req = '1' then
            if pending_reqs(current_floor) = '1' then
                req_served <= '1';
            else
                if dir = DIR_UP and current_floor < N_FLOORS - 1 then
                    floor_inc <= '1';
                elsif dir = DIR_DOWN and current_floor > 0 then
                    floor_dec <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clk, reset)
        variable min_distance   : integer;
        variable nearest_floor  : integer;
    begin
        if reset = '1' then
            dir <= DIR_UP;
        elsif rising_edge(clk) then
            if any_req = '1' then
                if dir = DIR_UP and current_floor = N_FLOORS - 1 and pending_reqs(current_floor) = '0' then
                    dir <= DIR_DOWN;
                elsif dir = DIR_DOWN and current_floor = 0 and pending_reqs(current_floor) = '0' then
                    dir <= DIR_UP;
                elsif pending_reqs(current_floor) = '0' and
                      floor_inc = '0' and floor_dec = '0' then
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
                        dir <= DIR_UP;
                    elsif nearest_floor < current_floor then
                        dir <= DIR_DOWN;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
