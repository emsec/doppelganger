library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity FSM is
    port (
        clk                        : in  std_logic;
        rst                        : in  std_logic;
        ctrl_receive_key           : in  std_logic;
        trng_available             : in  std_logic;
        receiver_available         : in  std_logic;
        bus_transmission_done      : in  std_logic;
        transmitter_ready_for_data : in  std_logic;
        receiver_byte_available    : in  std_logic;
        cipher_done                : in  std_logic;
        state                      : out std_logic_vector (3 downto 0);
        transitioning              : out std_logic;
        dummy_signals              : out std_logic_vector (3 downto 0)
    );
end FSM;

architecture arch of FSM is
    constant S_INIT           : std_logic_vector (3 downto 0) := "0000";
    constant S_CIPHER_ENCRYPT : std_logic_vector (3 downto 0) := "0001";
    constant S_TRANSMIT_IV    : std_logic_vector (3 downto 0) := "0011";
    constant S_GENERATE_IV    : std_logic_vector (3 downto 0) := "0111";
    constant S_RECEIVE_CTRL   : std_logic_vector (3 downto 0) := "1111";
    constant S_CIPHER_K       : std_logic_vector (3 downto 0) := "0010";
    constant S_CIPHER_P       : std_logic_vector (3 downto 0) := "0100";
    constant S_RECEIVE_KEY    : std_logic_vector (3 downto 0) := "0101";
    constant S_RECEIVE_P      : std_logic_vector (3 downto 0) := "0110";
    constant S_TRANSMIT_Y     : std_logic_vector (3 downto 0) := "1000";
    constant S_XOR_P          : std_logic_vector (3 downto 0) := "1001";
    constant S_XOR_STORE      : std_logic_vector (3 downto 0) := "1010";
    constant S_XOR_Y          : std_logic_vector (3 downto 0) := "1011";
    
    signal fsm                 : std_logic_vector (3 downto 0);
    signal fsm_enable          : std_logic;
    signal fsm_next            : std_logic_vector (3 downto 0);
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
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                fsm <= S_INIT;
            elsif (fsm_enable = '1') then
                fsm <= fsm_next;
            end if;
        end if;
    end process;
    
    transitioning <= fsm_enable;
    state <= fsm;
    is_S_INIT <= '1' when (fsm = S_INIT) else '0';
    is_S_RECEIVE_KEY <= '1' when (fsm = S_RECEIVE_KEY) else '0';
    is_S_CIPHER_P <= '1' when (fsm = S_CIPHER_P) else '0';
    is_S_RECEIVE_CTRL <= '1' when (fsm = S_RECEIVE_CTRL) else '0';
    is_S_RECEIVE_P <= '1' when (fsm = S_RECEIVE_P) else '0';
    is_S_CIPHER_K <= '1' when (fsm = S_CIPHER_K) else '0';
    is_S_XOR_P <= '1' when (fsm = S_XOR_P) else '0';
    is_S_CIPHER_ENCRYPT <= '1' when (fsm = S_CIPHER_ENCRYPT) else '0';
    is_S_GENERATE_IV <= '1' when (fsm = S_GENERATE_IV) else '0';
    is_S_TRANSMIT_IV <= '1' when (fsm = S_TRANSMIT_IV) else '0';
    is_S_TRANSMIT_Y <= '1' when (fsm = S_TRANSMIT_Y) else '0';
    is_S_XOR_STORE <= '1' when (fsm = S_XOR_STORE) else '0';
    is_S_XOR_Y <= '1' when (fsm = S_XOR_Y) else '0';
    fsm_enable <= (is_S_CIPHER_K and bus_transmission_done) or (is_S_RECEIVE_KEY and bus_transmission_done and receiver_available) or (is_S_TRANSMIT_Y and bus_transmission_done and transmitter_ready_for_data) or (is_S_XOR_Y and bus_transmission_done) or (is_S_INIT) or (is_S_GENERATE_IV and trng_available and bus_transmission_done) or (is_S_RECEIVE_CTRL and receiver_byte_available) or (is_S_RECEIVE_P and bus_transmission_done and receiver_available) or (is_S_XOR_STORE and bus_transmission_done) or (is_S_XOR_P and bus_transmission_done) or (is_S_CIPHER_P and bus_transmission_done) or (is_S_CIPHER_ENCRYPT and bus_transmission_done and cipher_DONE) or (is_S_TRANSMIT_IV and bus_transmission_done and transmitter_ready_for_data);
    fsm_next(0) <= (is_S_INIT) or (is_S_RECEIVE_CTRL and ctrl_receive_key) or (is_S_RECEIVE_P) or (is_S_XOR_P) or (is_S_CIPHER_K) or (is_S_TRANSMIT_Y) or (is_S_GENERATE_IV) or (is_S_TRANSMIT_IV) or (is_S_RECEIVE_KEY);
    fsm_next(1) <= (is_S_INIT) or (is_S_RECEIVE_CTRL and not ctrl_receive_key) or (is_S_XOR_P) or (is_S_XOR_Y) or (is_S_CIPHER_P) or (is_S_TRANSMIT_Y) or (is_S_TRANSMIT_IV) or (is_S_RECEIVE_KEY) or (is_S_GENERATE_IV);
    fsm_next(2) <= (is_S_INIT) or (is_S_RECEIVE_CTRL and ctrl_receive_key) or (is_S_RECEIVE_CTRL and not ctrl_receive_key) or (is_S_XOR_STORE) or (is_S_TRANSMIT_Y) or (is_S_TRANSMIT_IV) or (is_S_RECEIVE_KEY);
    fsm_next(3) <= (is_S_INIT) or (is_S_RECEIVE_P) or (is_S_XOR_P) or (is_S_XOR_Y) or (is_S_CIPHER_ENCRYPT and cipher_DONE) or (is_S_TRANSMIT_Y) or (is_S_TRANSMIT_IV);
    tmp <= "0000";
    dummy_signals <= tmp;
end arch;

