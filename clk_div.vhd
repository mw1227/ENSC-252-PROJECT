library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    Port (
        clk_50      : in  STD_LOGIC;
        reset_n     : in  STD_LOGIC;
        tick_1hz    : out STD_LOGIC
    );
end clk_div;

architecture Behavioral of clk_div is
    constant CLK_FREQ : integer := 50000000;
    signal counter    : integer range 0 to CLK_FREQ-1 := 0;
begin
    process(clk_50, reset_n)
    begin
        if reset_n = '0' then
            counter <= 0;
            tick_1hz <= '0';
        elsif rising_edge(clk_50) then
            if counter = CLK_FREQ - 1 then
                counter <= 0;
                tick_1hz <= '1';
            else
                counter <= counter + 1;
                tick_1hz <= '0';
            end if;
        end if;
    end process;
end Behavioral;