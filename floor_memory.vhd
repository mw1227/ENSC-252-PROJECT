library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Module: Floor Memory
-- Requirement Coverage:
-- GR-4: Track current floor and pending requests until served.
-- GR-5.a: Soft Reset (Clears requests, preserves floor).
-- GR-5.b: Hard Reset (Clears requests, resets floor to 0).
-- TR-3: Request Latching (Latched until arrival).
-- TR-7: Boundaries (Prevent illegal floor indices).

entity floor_memory is
    generic (
        N_FLOORS : integer := 4  -- GR-2: Support >= 4 floors
    );
    port (
        clk           : in std_logic;
        
        -- Reset Inputs (GR-5)
        hard_reset    : in std_logic; -- Resets EVERYTHING (Power-on default)
        soft_reset    : in std_logic; -- Resets requests only (Maintenance mode)
        
        -- Control Signals from FSM/Scheduler
        floor_inc     : in std_logic; -- Signal to increment floor count (Move Up)
        floor_dec     : in std_logic; -- Signal to decrement floor count (Move Down)
        req_served    : in std_logic; -- Signal that current floor request is done (Door Open)
        
        -- External Request Inputs (Buttons)
        request_btns  : in std_logic_vector(N_FLOORS-1 downto 0);
        
        -- Outputs to Scheduler and Display
        current_floor : out integer range 0 to N_FLOORS-1;
        pending_reqs  : out std_logic_vector(N_FLOORS-1 downto 0)
    );
end floor_memory;

architecture Behavioral of floor_memory is

    -- Internal Registers
    signal r_floor_index : integer range 0 to N_FLOORS-1 := 0;
    signal r_req_vector  : std_logic_vector(N_FLOORS-1 downto 0) := (others => '0');

begin

    -- ========================================================================
    -- PROCESS 1: CURRENT FLOOR TRACKING
    -- Implements GR-4 (Track Floor) and TR-7 (Boundaries)
    -- Implements GR-5.b (Hard Reset affects floor)
    -- Implements GR-5.a (Soft Reset does NOT affect floor)
    -- ========================================================================
    p_floor_counter : process(clk, hard_reset)
    begin
        if hard_reset = '1' then
            -- GR-5.b: Hard reset sets floor back to power-on default (Ground/0)
            r_floor_index <= 0;
        elsif rising_edge(clk) then
            -- Note: Soft reset is ignored here (GR-5.a preserves operational parameters)
            
            if floor_inc = '1' then
                -- TR-7: Boundary check, do not exceed top floor
                if r_floor_index < N_FLOORS - 1 then
                    r_floor_index <= r_floor_index + 1;
                end if;
            elsif floor_dec = '1' then
                -- TR-7: Boundary check, do not exceed bottom floor
                if r_floor_index > 0 then
                    r_floor_index <= r_floor_index - 1;
                end if;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- PROCESS 2: REQUEST LATCHING
    -- Implements GR-4 (Track Pending Requests) and TR-3 (Latching)
    -- Implements GR-5.a & GR-5.b (Both resets clear requests)
    -- ========================================================================
    p_request_latch : process(clk, hard_reset, soft_reset)
    begin
        -- Asynchronous Hard Reset (Safety)
        if hard_reset = '1' then
            r_req_vector <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Synchronous Soft Reset (GR-5.a)
            if soft_reset = '1' then
                r_req_vector <= (others => '0');
            else
                -- 1. Latch new requests (TR-3)
                for i in 0 to N_FLOORS-1 loop
                    if request_btns(i) = '1' then
                        r_req_vector(i) <= '1';
                    end if;
                end loop;

                -- 2. Clear served requests (TR-3)
                if req_served = '1' then
                    r_req_vector(r_floor_index) <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Output Assignments
    current_floor <= r_floor_index;
    pending_reqs  <= r_req_vector;

end Behavioral;