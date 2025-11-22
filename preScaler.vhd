library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity preScaler is
    Port (
        clk_in  : in  std_logic;  
        reset   : in  std_logic;
        clk_out : out std_logic   
    );
end preScaler;

architecture Behavioral of preScaler is
    constant N : integer := 50_000_000;
    signal counter : integer range 0 to N/2 := 0;
    signal clk_div : std_logic := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= 0;
            clk_div <= '0';
        elsif rising_edge(clk_in) then
            if counter = (N/2 - 1) then -- On 24,999,999
                counter <= 0;
                clk_div <= not clk_div;  
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_div;
end Behavioral;
