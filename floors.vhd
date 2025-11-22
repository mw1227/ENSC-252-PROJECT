library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floor_counter is
    generic (
        N_FLOORS : integer := 8;     -- up to 8 floors
        TRAVEL_TIME : integer := 3   -- seconds per floor
    );
    port (
        clk           : in  std_logic;
        reset_n       : in  std_logic;          -- active-low reset
        tick_1hz      : in  std_logic;          -- 1 Hz tick from prescaler
        move_up       : in  std_logic;
        move_down     : in  std_logic;
        current_floor : out unsigned(2 downto 0)
    );
end entity;

architecture rtl of floor_counter is
    signal floor_reg : unsigned(2 downto 0) := (others => '0');
    signal sec_count : unsigned(1 downto 0) := (others => '0');   -- counts 0,1,2
begin

    process(clk)
    begin
        if rising_edge(clk) then
        
            if reset_n = '0' then
                floor_reg <= (others => '0');
                sec_count <= (others => '0');

            elsif tick_1hz = '1' then
                -- increment 3-second timer
                if sec_count < (TRAVEL_TIME - 1) then
                    sec_count <= sec_count + 1;
                else
                    sec_count <= (others => '0');  -- reset timer

                    if move_up = '1' then
                        if floor_reg < (N_FLOORS - 1) then
                            floor_reg <= floor_reg + 1;
                        end if;

                    elsif move_down = '1' then
                        if floor_reg > 0 then
                            floor_reg <= floor_reg - 1;
                        end if;
                    end if;

                end if;
            end if;
        end if;
    end process;

    current_floor <= floor_reg;

end architecture;
