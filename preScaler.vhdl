library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clk_div is
generic (
INPUT_FREQ : natural := 50_000_000; -- Hz
OUTPUT_TICK_HZ: natural := 1 -- desired tick rate (Hz)
);
port (
clk_in : in std_logic;
reset_n : in std_logic; -- active low reset
tick : out std_logic -- one-clock pulse at OUTPUT_TICK_HZ
);
end entity;


architecture rtl of clk_div is
constant DIVCOUNT : natural := INPUT_FREQ / OUTPUT_TICK_HZ;
signal cnt : unsigned(31 downto 0) := (others => '0');
signal tick_r : std_logic := '0';
begin
process(clk_in, reset_n)
begin
if reset_n = '0' then
cnt <= (others => '0');
tick_r <= '0';
elsif rising_edge(clk_in) then
if cnt = to_unsigned(DIVCOUNT-1, cnt'length) then
cnt <= (others => '0');
tick_r <= '1';
else
cnt <= cnt + 1;
tick_r <= '0';
end if;
end if;
end process;


tick <= tick_r;
end architecture;