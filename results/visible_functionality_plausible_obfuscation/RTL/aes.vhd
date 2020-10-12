library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity AESCore is
    generic (
        BUS_SIZE : natural
    );
    port (
        clk           : in    std_logic;
        rst           : in    std_logic;
        start         : in    std_logic;
        done          : out   std_logic;
        read_from_bus : in    std_logic;
        write_to_bus  : in    std_logic;
        bus_line      : inout std_logic_vector (BUS_SIZE - 1 downto 0)
    );
end AESCore;

architecture arch of AESCore is
    component BusRegister
        generic (
            SIZE     : natural;
            BUS_SIZE : natural
        );
        port (
            clk           : in    std_logic;
            rst           : in    std_logic;
            input         : in    std_logic_vector (SIZE - 1 downto 0);
            load          : in    std_logic;
            output        : out   std_logic_vector (SIZE - 1 downto 0);
            read_from_bus : in    std_logic;
            write_to_bus  : in    std_logic;
            bus_line      : inout std_logic_vector (BUS_SIZE - 1 downto 0)
        );
    end component;
    
    component AESRoundFunction
        port (
            counter   : in  unsigned(3 downto 0);
            state     : in  std_logic_vector (127 downto 0);
            roundkey  : in  std_logic_vector (127 downto 0);
            new_state : out std_logic_vector (127 downto 0)
        );
    end component;
    
    component AESKeySchedule
        port (
            current_key : in  std_logic_vector (127 downto 0);
            counter     : in  unsigned(3 downto 0);
            next_key    : out std_logic_vector (127 downto 0)
        );
    end component;
    type fsm_1_state is (s_wait_for_start, s_wait_for_low);
    type fsm_2_state is (s_idle, s_encrypt);
    
    signal aes_cnt                       : unsigned(3 downto 0);
    signal aes_cnt_en                    : std_logic;
    signal aes_cnt_rst                   : std_logic;
    signal begin_encryption              : std_logic;
    signal bus_load_mux                  : std_logic;
    signal bus_read_cnt                  : natural range 0 to 2 * 128 / BUS_SIZE;
    signal bus_read_cnt_en               : std_logic;
    signal bus_read_cnt_rst              : std_logic;
    signal encryption_done               : std_logic;
    signal fsm_1_current_state           : fsm_1_state;
    signal fsm_1_next_state              : fsm_1_state;
    signal fsm_2_current_state           : fsm_2_state;
    signal fsm_2_next_state              : fsm_2_state;
    signal inst_key_reg_load             : std_logic;
    signal inst_key_reg_output           : std_logic_vector (127 downto 0);
    signal inst_key_reg_read_from_bus    : std_logic;
    signal inst_key_schedule_next_key    : std_logic_vector (127 downto 0);
    signal inst_round_function_new_state : std_logic_vector (127 downto 0);
    signal inst_state_reg_load           : std_logic;
    signal inst_state_reg_output         : std_logic_vector (127 downto 0);
    signal inst_state_reg_read_from_bus  : std_logic;
begin
    inst_state_reg : BusRegister
    generic map (
        SIZE     => 128,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => clk,
        rst           => rst,
        input         => inst_round_function_new_state,
        load          => inst_state_reg_load,
        output        => inst_state_reg_output,
        read_from_bus => inst_state_reg_read_from_bus,
        write_to_bus  => write_to_bus,
        bus_line      => bus_line
    );
    
    inst_key_reg : BusRegister
    generic map (
        SIZE     => 128,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => clk,
        rst           => rst,
        input         => inst_key_schedule_next_key,
        load          => inst_key_reg_load,
        output        => inst_key_reg_output,
        read_from_bus => inst_key_reg_read_from_bus,
        write_to_bus  => '0',
        bus_line      => bus_line
    );
    
    inst_round_function : AESRoundFunction
    port map (
        counter   => aes_cnt,
        state     => inst_state_reg_output,
        roundkey  => inst_key_reg_output,
        new_state => inst_round_function_new_state
    );
    
    inst_key_schedule : AESKeySchedule
    port map (
        current_key => inst_key_reg_output,
        counter     => aes_cnt,
        next_key    => inst_key_schedule_next_key
    );
    
    inst_state_reg_read_from_bus <= read_from_bus and bus_load_mux;
    inst_key_reg_read_from_bus <= read_from_bus and not bus_load_mux;
    done <= encryption_done and not begin_encryption;
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                fsm_1_current_state <= s_wait_for_start;
            else
                fsm_1_current_state <= fsm_1_next_state;
            end if;
        end if;
    end process;
    process(start, fsm_1_current_state)
    begin
        -- default assignments
        fsm_1_next_state <= fsm_1_current_state;
        begin_encryption <= '0';
            -- state transitions
            case fsm_1_current_state is
                when s_wait_for_start =>
                    if (start = '1') then
                        begin_encryption <= '1';
                            fsm_1_next_state <= s_wait_for_low;
                        end if;
                        ----------------------------------------
                        when s_wait_for_low =>
                            if (start = '0') then
                                fsm_1_next_state <= s_wait_for_start;
                            end if;
                            ----------------------------------------
                    end case;
                end process;
                
                process(clk)
                begin
                    if rising_edge(clk) then
                        if (rst = '1') then
                            fsm_2_current_state <= s_idle;
                        else
                            fsm_2_current_state <= fsm_2_next_state;
                        end if;
                    end if;
                end process;
                process(fsm_2_current_state, aes_cnt, read_from_bus, bus_read_cnt, begin_encryption)
                begin
                    -- default assignments
                    fsm_2_next_state <= fsm_2_current_state;
                    inst_state_reg_load <= '0';
                    inst_key_reg_load <= '0';
                    encryption_done <= '0';
                    aes_cnt_en <= '0';
                    aes_cnt_rst <= '0';
                    bus_read_cnt_rst <= '0';
                    bus_read_cnt_en <= '0';
                    bus_load_mux <= '0';
                    -- state transitions
                    case fsm_2_current_state is
                        when s_idle =>
                            encryption_done <= '1';
                            if (read_from_bus = '1') then
                                if (bus_read_cnt <= 128 / BUS_SIZE - 1) then
                                    bus_load_mux <= '1';
                                end if;
                                bus_read_cnt_en <= '1';
                            end if;
                            if (begin_encryption = '1') then
                                fsm_2_next_state <= s_encrypt;
                                aes_cnt_rst <= '1';
                            end if;
                            ----------------------------------------
                        when s_encrypt =>
                            inst_state_reg_load <= '1';
                            inst_key_reg_load <= '1';
                            aes_cnt_en <= '1';
                            if (aes_cnt = "1010") then
                                bus_read_cnt_rst <= '1';
                                fsm_2_next_state <= s_idle;
                            end if;
                            ----------------------------------------
                    end case;
                end process;
                
                process(clk)
                begin
                    if rising_edge(clk) then
                        if (aes_cnt_rst = '1') then
                            aes_cnt <= "0000";
                        elsif (aes_cnt_en = '1') then
                            aes_cnt <= aes_cnt + 1;
                        end if;
                        if (bus_read_cnt_rst = '1') then
                            bus_read_cnt <= 0;
                        elsif (bus_read_cnt_en = '1') then
                            bus_read_cnt <= bus_read_cnt + 1;
                        end if;
                    end if;
                end process;
                
            end arch;
            
