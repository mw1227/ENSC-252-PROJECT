library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div_tb is
end clk_div_tb;

architecture Behavioral of clk_div_tb is

    component clk_div
        Port (
            clk_50   : in  STD_LOGIC;
            reset_n  : in  STD_LOGIC;
            tick_1hz : out STD_LOGIC
        );
    end component;

    signal clk_50  : std_logic := '0';
    signal reset_n : std_logic := '0';

    signal tick_1hz : std_logic;

    constant clk_period : time := 20 ns;

begin

    uut: clk_div Port Map (
        clk_50   => clk_50,
        reset_n  => reset_n,
        tick_1hz => tick_1hz
    );

    clk_process : process
    begin
        clk_50 <= '0';
        wait for clk_period/2;
        clk_50 <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        reset_n <= '0';
        wait for 100 ns;
        
        reset_n <= '1';

        wait for 1000 ms; 
        

        wait for 10000 ns;

    end process;

end Behavioral;