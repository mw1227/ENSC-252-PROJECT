library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity floor_memory is
    generic (
        N_FLOORS : integer := 4 
    );
    port (
        clk           : in std_logic;
        hard_reset    : in std_logic; 
        soft_reset    : in std_logic; 
        -- Control signals from FSM
        floor_inc     : in std_logic; 
        floor_dec     : in std_logic; 
        req_served    : in std_logic; 
        -- External
        request_btns  : in std_logic_vector(N_FLOORS-1 downto 0);
        -- Outputs
        current_floor : out integer range 0 to N_FLOORS-1;
        pending_reqs  : out std_logic_vector(N_FLOORS-1 downto 0)
    );
end floor_memory;

architecture Behavioral of floor_memory is
    signal r_floor_index : integer range 0 to N_FLOORS-1 := 0;
    signal r_req_vector  : std_logic_vector(N_FLOORS-1 downto 0) := (others => '0');
begin

    -- Position Tracking
    process(clk, hard_reset)
    begin
        if hard_reset = '1' then
            r_floor_index <= 0; 
        elsif rising_edge(clk) then
            if floor_inc = '1' then
                if r_floor_index < N_FLOORS - 1 then
                    r_floor_index <= r_floor_index + 1;
                end if;
            elsif floor_dec = '1' then
                if r_floor_index > 0 then
                    r_floor_index <= r_floor_index - 1;
                end if;
            end if;
        end if;
    end process;

    -- Request Latching
    process(clk, hard_reset)
    begin
        if hard_reset = '1' then
            r_req_vector <= (others => '0');
        elsif rising_edge(clk) then
            if soft_reset = '1' then
                r_req_vector <= (others => '0');
            else
                -- Latch Inputs
                for i in 0 to N_FLOORS-1 loop
                    if request_btns(i) = '1' then
                        r_req_vector(i) <= '1';
                    end if;
                end loop;
                
                -- Clear Served
                if req_served = '1' then
                    r_req_vector(r_floor_index) <= '0';
                end if;
            end if;
        end if;
    end process;

    current_floor <= r_floor_index;
    pending_reqs  <= r_req_vector;

end Behavioral;