library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scheduler_sweep is
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
end scheduler_sweep;