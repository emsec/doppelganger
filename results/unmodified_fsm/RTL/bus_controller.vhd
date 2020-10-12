library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity BusController is
    generic (
        BUS_SIZE    : natural := 16;
        DATA_LENGTH : natural := 128
    );
    port (
        clk                        : in  std_logic;
        fsm_state                  : in  std_logic_vector (3 downto 0);
        fsm_transitioning          : in  std_logic;
        transmitter_ready_for_data : in  std_logic;
        trng_available             : in  std_logic;
        receiver_available         : in  std_logic;
        cipher_done                : in  std_logic;
        src_address                : out std_logic_vector (3 downto 0);
        dst_address                : out std_logic_vector (3 downto 0);
        transmission_done          : out std_logic;
        dummy_signals              : out std_logic_vector (3 downto 0)
    );
end BusController;

architecture arch of BusController is
    constant BUS_CNT_MAX                 : natural := DATA_LENGTH / BUS_SIZE - 1;
    constant BUS_ID_NOBODY               : std_logic_vector (3 downto 0) := "0000";
    constant BUS_ID_RECEIVER             : std_logic_vector (3 downto 0) := "0001";
    constant BUS_ID_TRANSMITTER          : std_logic_vector (3 downto 0) := "0010";
    constant BUS_ID_P_REG                : std_logic_vector (3 downto 0) := "0011";
    constant BUS_ID_Y_REG                : std_logic_vector (3 downto 0) := "0100";
    constant BUS_ID_K_REG                : std_logic_vector (3 downto 0) := "0101";
    constant BUS_ID_TRNG                 : std_logic_vector (3 downto 0) := "0110";
    constant BUS_ID_XOR                  : std_logic_vector (3 downto 0) := "0111";
    constant BUS_ID_CIPHER               : std_logic_vector (3 downto 0) := "1000";
    constant global_FSM_S_INIT           : std_logic_vector (3 downto 0) := "0000";
    constant global_FSM_S_RECEIVE_KEY    : std_logic_vector (3 downto 0) := "0010";
    constant global_FSM_S_CIPHER_P       : std_logic_vector (3 downto 0) := "1001";
    constant global_FSM_S_RECEIVE_CTRL   : std_logic_vector (3 downto 0) := "0001";
    constant global_FSM_S_RECEIVE_P      : std_logic_vector (3 downto 0) := "0101";
    constant global_FSM_S_CIPHER_K       : std_logic_vector (3 downto 0) := "1010";
    constant global_FSM_S_XOR_P          : std_logic_vector (3 downto 0) := "0110";
    constant global_FSM_S_CIPHER_ENCRYPT : std_logic_vector (3 downto 0) := "1011";
    constant global_FSM_S_GENERATE_IV    : std_logic_vector (3 downto 0) := "0011";
    constant global_FSM_S_TRANSMIT_IV    : std_logic_vector (3 downto 0) := "0100";
    constant global_FSM_S_TRANSMIT_Y     : std_logic_vector (3 downto 0) := "1100";
    constant global_FSM_S_XOR_STORE      : std_logic_vector (3 downto 0) := "1000";
    constant global_FSM_S_XOR_Y          : std_logic_vector (3 downto 0) := "0111";

    signal bus_active          : std_logic;
    signal bus_cnt             : natural range 0 to BUS_CNT_MAX;
    signal bus_cnt_max_reached : std_logic;
    signal bus_dst             : std_logic_vector (3 downto 0);
    signal bus_src             : std_logic_vector (3 downto 0);
    signal is_S_CIPHER_ENCRYPT : std_logic;
    signal is_S_CIPHER_K       : std_logic;
    signal is_S_CIPHER_P       : std_logic;
    signal is_S_GENERATE_IV    : std_logic;
    signal is_S_INIT           : std_logic;
    signal is_S_RECEIVE_CTRL   : std_logic;
    signal is_S_RECEIVE_KEY    : std_logic;
    signal is_S_RECEIVE_P      : std_logic;
    signal is_S_TRANSMIT_IV    : std_logic;
    signal is_S_TRANSMIT_Y     : std_logic;
    signal is_S_XOR_P          : std_logic;
    signal is_S_XOR_STORE      : std_logic;
    signal is_S_XOR_Y          : std_logic;
    signal tmp                 : std_logic_vector (3 downto 0);
begin
    bus_cnt_max_reached <= '1' when (bus_cnt = BUS_CNT_MAX) else '0';
    bus_active <= '0' when (bus_dst = BUS_ID_NOBODY) else '1';
    process(clk)
    begin
        if rising_edge(clk) then
            if (fsm_transitioning = '1') then
                bus_cnt <= 0;
            elsif ((not bus_cnt_max_reached and bus_active) = '1') then
                bus_cnt <= bus_cnt + 1;
            end if;
        end if;
    end process;

    src_address <= bus_src;
    dst_address <= bus_dst;
    transmission_done <= bus_cnt_max_reached;
    is_S_INIT <= '1' when (fsm_state = global_FSM_S_INIT) else '0';
    is_S_RECEIVE_KEY <= '1' when (fsm_state = global_FSM_S_RECEIVE_KEY) else '0';
    is_S_CIPHER_P <= '1' when (fsm_state = global_FSM_S_CIPHER_P) else '0';
    is_S_RECEIVE_CTRL <= '1' when (fsm_state = global_FSM_S_RECEIVE_CTRL) else '0';
    is_S_RECEIVE_P <= '1' when (fsm_state = global_FSM_S_RECEIVE_P) else '0';
    is_S_CIPHER_K <= '1' when (fsm_state = global_FSM_S_CIPHER_K) else '0';
    is_S_XOR_P <= '1' when (fsm_state = global_FSM_S_XOR_P) else '0';
    is_S_CIPHER_ENCRYPT <= '1' when (fsm_state = global_FSM_S_CIPHER_ENCRYPT) else '0';
    is_S_GENERATE_IV <= '1' when (fsm_state = global_FSM_S_GENERATE_IV) else '0';
    is_S_TRANSMIT_IV <= '1' when (fsm_state = global_FSM_S_TRANSMIT_IV) else '0';
    is_S_TRANSMIT_Y <= '1' when (fsm_state = global_FSM_S_TRANSMIT_Y) else '0';
    is_S_XOR_STORE <= '1' when (fsm_state = global_FSM_S_XOR_STORE) else '0';
    is_S_XOR_Y <= '1' when (fsm_state = global_FSM_S_XOR_Y) else '0';
    bus_src(0) <= (is_S_RECEIVE_KEY and receiver_available) or (is_S_TRANSMIT_IV and transmitter_ready_for_data) or (is_S_RECEIVE_P and receiver_available) or (is_S_XOR_P) or (is_S_XOR_STORE) or (is_S_CIPHER_P) or (is_S_CIPHER_K);
    bus_src(1) <= (is_S_GENERATE_IV and trng_available) or (is_S_XOR_P) or (is_S_XOR_STORE) or (is_S_CIPHER_P);
    bus_src(2) <= (is_S_GENERATE_IV and trng_available) or (is_S_TRANSMIT_IV and transmitter_ready_for_data) or (is_S_XOR_Y) or (is_S_XOR_STORE) or (is_S_CIPHER_K) or (is_S_TRANSMIT_Y and transmitter_ready_for_data);
    bus_src(3) <= (is_S_CIPHER_ENCRYPT and cipher_done);
    bus_dst(0) <= (is_S_RECEIVE_KEY and receiver_available) or (is_S_RECEIVE_P and receiver_available) or (is_S_XOR_P) or (is_S_XOR_Y) or (is_S_XOR_STORE);
    bus_dst(1) <= (is_S_RECEIVE_P and receiver_available) or (is_S_XOR_P) or (is_S_XOR_Y) or (is_S_XOR_STORE) or (is_S_TRANSMIT_Y and transmitter_ready_for_data);
    bus_dst(2) <= (is_S_RECEIVE_KEY and receiver_available) or (is_S_XOR_P) or (is_S_XOR_Y) or (is_S_CIPHER_ENCRYPT and cipher_done);
    bus_dst(3) <= (is_S_GENERATE_IV and trng_available) or (is_S_TRANSMIT_IV and transmitter_ready_for_data) or (is_S_CIPHER_P) or (is_S_CIPHER_K);
    tmp(0) <= '0';
    tmp(1) <= '0';
    tmp(2) <= '0';
    tmp(3) <= '0';
    dummy_signals <= tmp;
end arch;

