library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity Extended_UART_Transmitter is
    generic (
        CLK_FREQUENCY : natural;
        BAUD_RATE     : natural;
        BUS_SIZE      : natural
    );
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        RS232_BIT      : out std_logic;
        send_enable    : in  std_logic;
        bus_line       : in  std_logic_vector (BUS_SIZE - 1 downto 0);
        ready_for_data : out std_logic
    );
end Extended_UART_Transmitter;

architecture arch of Extended_UART_Transmitter is
    component UART_Transmitter
        generic (
            CLK_FREQUENCY : natural;
            BAUD_RATE     : natural
        );
        port (
            CLK            : in  std_logic;
            RST            : in  std_logic;
            TX_DATA        : in  std_logic_vector (7 downto 0);
            SEND_ENABLE    : in  std_logic;
            RS232_BIT      : out std_logic;
            READY_FOR_DATA : out std_logic
        );
    end component;
    type fsm_1_state is (S_IDLE, S_SEND, S_WAIT_FOR_SEND);
    
    signal CNT_EN                          : std_logic;
    signal CNT_RST                         : std_logic;
    signal COUNT                           : natural range 0 to BUS_SIZE / 8 + 1;
    signal REG                             : std_logic_vector (BUS_SIZE - 1 downto 0);
    signal REG_EN                          : std_logic;
    signal REG_LOAD                        : std_logic;
    signal fsm_1_current_state             : fsm_1_state;
    signal fsm_1_next_state                : fsm_1_state;
    signal inst_transmitter_READY_FOR_DATA : std_logic;
    signal inst_transmitter_SEND_ENABLE    : std_logic;
begin
    inst_transmitter : UART_Transmitter
    generic map (
        CLK_FREQUENCY => CLK_FREQUENCY,
        BAUD_RATE     => BAUD_RATE
    )
    port map (
        CLK            => CLK,
        RST            => RST,
        TX_DATA        => REG((BUS_SIZE) - 1 downto BUS_SIZE - 8),
        SEND_ENABLE    => inst_transmitter_SEND_ENABLE,
        RS232_BIT      => RS232_BIT,
        READY_FOR_DATA => inst_transmitter_READY_FOR_DATA
    );
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (CNT_RST = '1') then
                COUNT <= 0;
            elsif (CNT_EN = '1') then
                COUNT <= COUNT + 1;
            end if;
            if (REG_LOAD = '1') then
                REG <= bus_line;
            elsif (REG_EN = '1') then
                REG <= REG((BUS_SIZE) - 9 DOWNTO 0) & "00000000";
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                fsm_1_current_state <= S_IDLE;
            else
                fsm_1_current_state <= fsm_1_next_state;
            end if;
        end if;
    end process;
    process(count, inst_transmitter_ready_for_data, fsm_1_current_state, send_enable)
    begin
        -- default assignments
        fsm_1_next_state <= fsm_1_current_state;
        CNT_RST <= '0';
        CNT_EN <= '0';
        REG_EN <= '0';
        REG_LOAD <= '0';
        READY_FOR_DATA <= '0';
        inst_transmitter_SEND_ENABLE <= '0';
        -- state transitions
        case fsm_1_current_state is
            when S_IDLE =>
                READY_FOR_DATA <= '1';
                CNT_RST <= '1';
                if (SEND_ENABLE = '1') then
                    REG_LOAD <= '1';
                    fsm_1_next_state <= S_SEND;
                end if;
                ----------------------------------------
            when S_SEND =>
                inst_transmitter_SEND_ENABLE <= '1';
                CNT_EN <= '1';
                fsm_1_next_state <= S_WAIT_FOR_SEND;
                ----------------------------------------
            when S_WAIT_FOR_SEND =>
                if (inst_transmitter_READY_FOR_DATA = '1') then
                    REG_EN <= '1';
                    if (COUNT = BUS_SIZE / 8) then
                        fsm_1_next_state <= S_IDLE;
                    else
                        fsm_1_next_state <= S_SEND;
                    end if;
                end if;
                ----------------------------------------
        end case;
    end process;
    
end arch;
