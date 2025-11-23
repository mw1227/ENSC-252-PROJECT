library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Module: Floor Manager
-- Combines: floor_memory (Request Latching) + floors (Position Tracking)
-- Role: Stores the state of the elevator (Position + Buttons)
-- Controlled by: controller_fsm (which handles the timing)

entity floor_manager is
    generic (
        N_FLOORS : integer := 4  -- Number of floors (GR-2)
    );
    port (
        clk           : in std_logic;
        
        -- System Inputs
        hard_reset    : in std_logic; -- System Reset (GR-5b: Clears Floor & Reqs)
        soft_reset    : in std_logic; -- Maintenance Reset (GR-5a: Clears Reqs only)
        estop         : in std_logic; -- Emergency Stop (Freezes state)
        
        -- Control Signals (From Controller FSM)
        -- Note: These should be single-cycle pulses from the FSM
        floor_inc     : in std_logic; -- "Move Up 1 Floor"
        floor_dec     : in std_logic; -- "Move Down 1 Floor"
        req_served    : in std_logic; -- "Clear Request at Current Floor"
        
        -- User Inputs
        request_btns  : in std_logic_vector(N_FLOORS-1 downto 0); -- Raw button inputs
        
        -- Outputs (To FSM and Display)
        current_floor : out integer range 0 to N_FLOORS-1;
        pending_reqs  : out std_logic_vector(N_FLOORS-1 downto 0)
    );
end floor_manager;

architecture Behavioral of floor_manager is

    -- Internal Registers
    signal r_floor_index : integer range 0 to N_FLOORS-1 := 0;
    signal r_req_vector  : std_logic_vector(N_FLOORS-1 downto 0) := (others => '0');

begin

    -- ========================================================================
    -- PROCESS 1: POSITION TRACKING (Formerly floors.vhd)
    -- ========================================================================
    -- Handles GR-4 (Track Floor) and TR-7 (Boundaries)
    p_floor_counter : process(clk, hard_reset)
    begin
        -- Asynchronous Hard Reset (GR-5b)
        if hard_reset = '1' then
            r_floor_index <= 0; -- Reset to bottom floor
            
        elsif rising_edge(clk) then
            -- ESTOP Freeze Override
            if estop = '0' then 
                
                -- Move Up Logic
                if floor_inc = '1' then
                    -- TR-7 Boundary Check
                    if r_floor_index < N_FLOORS - 1 then
                        r_floor_index <= r_floor_index + 1;
                    end if;
                
                -- Move Down Logic
                elsif floor_dec = '1' then
                    -- TR-7 Boundary Check
                    if r_floor_index > 0 then
                        r_floor_index <= r_floor_index - 1;
                    end if;
                end if;
                
            end if; -- End ESTOP check
        end if;
    end process;

    -- ========================================================================
    -- PROCESS 2: REQUEST MEMORY (Formerly floor_memory.vhd)
    -- ========================================================================
    -- Handles GR-4 (Track Reqs), TR-3 (Latching), and GR-5a (Soft Reset)
    p_request_latch : process(clk, hard_reset)
    begin
        -- Asynchronous Hard Reset (Clears everything)
        if hard_reset = '1' then
            r_req_vector <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Synchronous Soft Reset (GR-5a: Clears requests, keeps floor)
            if soft_reset = '1' then
                r_req_vector <= (others => '0');
            else
                -- 1. Latch New Requests (TR-3)
                -- We loop through inputs to catch any button press
                for i in 0 to N_FLOORS-1 loop
                    if request_btns(i) = '1' then
                        r_req_vector(i) <= '1';
                    end if;
                end loop;

                -- 2. Clear Served Requests (TR-3)
                -- Only clear when the FSM says we have arrived and opened door
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