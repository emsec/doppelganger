library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity Top is
    port (
        CLK           : in  std_logic;
        RST           : in  std_logic;
        UART_RX       : in  std_logic;
        UART_TX       : out std_logic;
        dummy_signals : out std_logic_vector (3 downto 0)
    );
end Top;

architecture arch of Top is
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
    
    component BusController
        generic (
            BUS_SIZE    : natural;
            DATA_LENGTH : natural
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
            transmission_done          : out std_logic
        );
    end component;
    
    component Receiver
        generic (
            BUS_SIZE : natural
        );
        port (
            clk                : in  std_logic;
            rst                : in  std_logic;
            UART_RX            : in  std_logic;
            write_to_bus       : in  std_logic;
            bus_line           : out std_logic_vector (BUS_SIZE - 1 downto 0);
            available          : out std_logic;
            byte_available     : out std_logic;
            last_received_byte : out std_logic_vector (7 downto 0)
        );
    end component;
    
    component TRNG
        generic (
            BUS_SIZE : natural
        );
        port (
            clk          : in    std_logic;
            start        : in    std_logic;
            rst          : in    std_logic;
            write_to_bus : in    std_logic;
            bus_line     : inout std_logic_vector (BUS_SIZE - 1 downto 0);
            available    : out   std_logic
        );
    end component;
    
    component FSM
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
    end component;
    
    component AESCore
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
    end component;
    
    component BusXOR
        generic (
            SIZE     : natural;
            BUS_SIZE : natural
        );
        port (
            clk           : in    std_logic;
            rst           : in    std_logic;
            read_from_bus : in    std_logic;
            write_to_bus  : in    std_logic;
            bus_line      : inout std_logic_vector (BUS_SIZE - 1 downto 0)
        );
    end component;
    
    component Transmitter
        generic (
            BUS_SIZE : natural
        );
        port (
            clk            : in  std_logic;
            rst            : in  std_logic;
            UART_TX        : out std_logic;
            read_from_bus  : in  std_logic;
            bus_line       : in  std_logic_vector (BUS_SIZE - 1 downto 0);
            ready_for_data : out std_logic
        );
    end component;
    constant BUS_SIZE                                : natural := 16;
    constant DATA_LENGTH                             : natural := 128;
    constant global_FSM_S_RECEIVE_P                  : std_logic_vector (3 downto 0) := "0110";
    constant global_FSM_S_RECEIVE_CTRL               : std_logic_vector (3 downto 0) := "1111";
    constant global_FSM_S_INIT                       : std_logic_vector (3 downto 0) := "0000";
    constant global_FSM_S_CIPHER_ENCRYPT             : std_logic_vector (3 downto 0) := "0001";
    constant global_BusController_BUS_ID_RECEIVER    : std_logic_vector (3 downto 0) := "0110";
    constant global_BusController_BUS_ID_TRANSMITTER : std_logic_vector (3 downto 0) := "0101";
    constant global_BusController_BUS_ID_Y_REG       : std_logic_vector (3 downto 0) := "0011";
    constant global_BusController_BUS_ID_K_REG       : std_logic_vector (3 downto 0) := "0010";
    constant global_BusController_BUS_ID_P_REG       : std_logic_vector (3 downto 0) := "0100";
    constant global_BusController_BUS_ID_TRNG        : std_logic_vector (3 downto 0) := "0111";
    constant global_BusController_BUS_ID_CIPHER      : std_logic_vector (3 downto 0) := "0001";
    constant global_BusController_BUS_ID_XOR         : std_logic_vector (3 downto 0) := "1000";
    
    signal ctrl_receive_key                 : std_logic;
    signal data_bus                         : std_logic_vector (BUS_SIZE - 1 downto 0);
    signal in_s_init                        : std_logic;
    signal in_s_receive_P                   : std_logic;
    signal in_s_receive_ctrl                : std_logic;
    signal inst_bus_ctrl_dst_address        : std_logic_vector (3 downto 0);
    signal inst_bus_ctrl_src_address        : std_logic_vector (3 downto 0);
    signal inst_bus_ctrl_transmission_done  : std_logic;
    signal inst_cipher_done                 : std_logic;
    signal inst_cipher_read_from_bus        : std_logic;
    signal inst_cipher_start                : std_logic;
    signal inst_cipher_write_to_bus         : std_logic;
    signal inst_fsm_dummy_signals           : std_logic_vector (3 downto 0);
    signal inst_fsm_state                   : std_logic_vector (3 downto 0);
    signal inst_fsm_transitioning           : std_logic;
    signal inst_k_reg_read_from_bus         : std_logic;
    signal inst_k_reg_write_to_bus          : std_logic;
    signal inst_p_reg_read_from_bus         : std_logic;
    signal inst_p_reg_write_to_bus          : std_logic;
    signal inst_receiver_available          : std_logic;
    signal inst_receiver_byte_available     : std_logic;
    signal inst_receiver_last_received_byte : std_logic_vector (7 downto 0);
    signal inst_receiver_write_to_bus       : std_logic;
    signal inst_transmitter_read_from_bus   : std_logic;
    signal inst_transmitter_ready_for_data  : std_logic;
    signal inst_trng_available              : std_logic;
    signal inst_trng_start                  : std_logic;
    signal inst_trng_write_to_bus           : std_logic;
    signal inst_xor_module_read_from_bus    : std_logic;
    signal inst_xor_module_rst              : std_logic;
    signal inst_xor_module_write_to_bus     : std_logic;
    signal inst_y_reg_read_from_bus         : std_logic;
    signal inst_y_reg_write_to_bus          : std_logic;
    signal reset_core                       : std_logic;
    signal reset_rxtx                       : std_logic;
begin
    inst_cipher : AESCore
    generic map (
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => CLK,
        rst           => reset_core,
        start         => inst_cipher_start,
        done          => inst_cipher_done,
        read_from_bus => inst_cipher_read_from_bus,
        write_to_bus  => inst_cipher_write_to_bus,
        bus_line      => data_bus
    );
    
    inst_trng : TRNG
    generic map (
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk          => CLK,
        start        => inst_trng_start,
        rst          => RST,
        write_to_bus => inst_trng_write_to_bus,
        bus_line     => data_bus,
        available    => inst_trng_available
    );
    
    inst_transmitter : Transmitter
    generic map (
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk            => CLK,
        rst            => reset_rxtx,
        UART_TX        => UART_TX,
        read_from_bus  => inst_transmitter_read_from_bus,
        bus_line       => data_bus,
        ready_for_data => inst_transmitter_ready_for_data
    );
    
    inst_receiver : Receiver
    generic map (
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk                => CLK,
        rst                => reset_rxtx,
        UART_RX            => UART_RX,
        write_to_bus       => inst_receiver_write_to_bus,
        bus_line           => data_bus,
        available          => inst_receiver_available,
        byte_available     => inst_receiver_byte_available,
        last_received_byte => inst_receiver_last_received_byte
    );
    
    inst_p_reg : BusRegister
    generic map (
        SIZE     => DATA_LENGTH,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => CLK,
        rst           => reset_core,
        input         => (OTHERS => '0'),
        load          => '0',
        output        => open,
        read_from_bus => inst_p_reg_read_from_bus,
        write_to_bus  => inst_p_reg_write_to_bus,
        bus_line      => data_bus
    );
    
    inst_y_reg : BusRegister
    generic map (
        SIZE     => DATA_LENGTH,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => CLK,
        rst           => reset_core,
        input         => (OTHERS => '0'),
        load          => '0',
        output        => open,
        read_from_bus => inst_y_reg_read_from_bus,
        write_to_bus  => inst_y_reg_write_to_bus,
        bus_line      => data_bus
    );
    
    inst_k_reg : BusRegister
    generic map (
        SIZE     => DATA_LENGTH,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => CLK,
        rst           => reset_core,
        input         => (OTHERS => '0'),
        load          => '0',
        output        => open,
        read_from_bus => inst_k_reg_read_from_bus,
        write_to_bus  => inst_k_reg_write_to_bus,
        bus_line      => data_bus
    );
    
    inst_xor_module : BusXOR
    generic map (
        SIZE     => DATA_LENGTH,
        BUS_SIZE => BUS_SIZE
    )
    port map (
        clk           => CLK,
        rst           => inst_xor_module_rst,
        read_from_bus => inst_xor_module_read_from_bus,
        write_to_bus  => inst_xor_module_write_to_bus,
        bus_line      => data_bus
    );
    
    inst_fsm : FSM
    port map (
        clk                        => CLK,
        rst                        => RST,
        ctrl_receive_key           => ctrl_receive_key,
        trng_available             => inst_trng_available,
        receiver_available         => inst_receiver_available,
        bus_transmission_done      => inst_bus_ctrl_transmission_done,
        transmitter_ready_for_data => inst_transmitter_ready_for_data,
        receiver_byte_available    => inst_receiver_byte_available,
        cipher_done                => inst_cipher_done,
        state                      => inst_fsm_state,
        transitioning              => inst_fsm_transitioning,
        dummy_signals              => inst_fsm_dummy_signals
    );
    
    inst_bus_ctrl : BusController
    generic map (
        BUS_SIZE    => BUS_SIZE,
        DATA_LENGTH => DATA_LENGTH
    )
    port map (
        clk                        => CLK,
        fsm_state                  => inst_fsm_state,
        fsm_transitioning          => inst_fsm_transitioning,
        transmitter_ready_for_data => inst_transmitter_ready_for_data,
        trng_available             => inst_trng_available,
        receiver_available         => inst_receiver_available,
        cipher_done                => inst_cipher_done,
        src_address                => inst_bus_ctrl_src_address,
        dst_address                => inst_bus_ctrl_dst_address,
        transmission_done          => inst_bus_ctrl_transmission_done
    );
    
    dummy_signals <= inst_fsm_dummy_signals;
    ctrl_receive_key <= '1' when (inst_receiver_last_received_byte = x"00") else '0';
    in_s_receive_P <= '1' when (inst_fsm_state = global_FSM_S_RECEIVE_P) else '0';
    in_s_receive_ctrl <= '1' when (inst_fsm_state = global_FSM_S_RECEIVE_CTRL) else '0';
    in_s_init <= '1' when (inst_fsm_state = global_FSM_S_INIT) else '0';
    inst_xor_module_rst <= (in_s_receive_P and inst_receiver_available and inst_bus_ctrl_transmission_done);
    inst_trng_start <= (in_s_receive_ctrl and inst_receiver_byte_available and ctrl_receive_key);
    reset_core <= in_s_init or (in_s_receive_ctrl and inst_receiver_byte_available and ctrl_receive_key);
    reset_rxtx <= in_s_init or (in_s_receive_ctrl and inst_receiver_byte_available);
    inst_cipher_start <= '1' when (inst_fsm_state = global_FSM_S_CIPHER_ENCRYPT) else '0';
    
    inst_receiver_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_RECEIVER) else '0';
    
    inst_transmitter_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_TRANSMITTER) else '0';
    
    inst_y_reg_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_Y_REG) else '0';
    inst_y_reg_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_Y_REG) else '0';
    
    inst_k_reg_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_K_REG) else '0';
    inst_k_reg_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_K_REG) else '0';
    
    inst_p_reg_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_P_REG) else '0';
    inst_p_reg_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_P_REG) else '0';
    
    inst_trng_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_TRNG) else '0';
    
    inst_cipher_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_CIPHER) else '0';
    inst_cipher_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_CIPHER) else '0';
    
    inst_xor_module_write_to_bus <= '1' when (inst_bus_ctrl_src_address = global_BusController_BUS_ID_XOR) else '0';
    inst_xor_module_read_from_bus <= '1' when (inst_bus_ctrl_dst_address = global_BusController_BUS_ID_XOR) else '0';
    
end arch;

