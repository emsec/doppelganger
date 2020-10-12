library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity UART_Transmitter is
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
end UART_Transmitter;

architecture arch of UART_Transmitter is
    type fsm_1_state is (S_RESET, S_READY, S_SENDING);
    
    constant BIT_SENDING_TIME : natural := CLK_FREQUENCY / BAUD_RATE;
    
    signal BIT_CNT             : natural range 0 to 10;
    signal CNT_EN              : std_logic;
    signal CNT_RST             : std_logic;
    signal SEND_CNT            : natural range 0 to BIT_SENDING_TIME;
    signal fsm_1_current_state : fsm_1_state;
    signal fsm_1_next_state    : fsm_1_state;
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (CNT_RST = '1') then
                SEND_CNT <= 0;
                BIT_CNT <= 0;
            elsif (CNT_EN = '1') then
                if (SEND_CNT < BIT_SENDING_TIME) then
                    SEND_CNT <= SEND_CNT + 1;
                else
                    SEND_CNT <= 0;
                    BIT_CNT <= BIT_CNT + 1;
                end if;
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1') then
                fsm_1_current_state <= S_RESET;
            else
                fsm_1_current_state <= fsm_1_next_state;
            end if;
        end if;
    end process;
    process(send_enable, bit_cnt, tx_data, fsm_1_current_state)
    begin
        -- default assignments
        fsm_1_next_state <= fsm_1_current_state;
        CNT_EN <= '0';
        CNT_RST <= '0';
        READY_FOR_DATA <= '0';
        RS232_BIT <= '1';
        -- state transitions
        case fsm_1_current_state is
            when S_RESET =>
                READY_FOR_DATA <= '1';
                fsm_1_next_state <= S_READY;
                ----------------------------------------
            when S_READY =>
                if (SEND_ENABLE = '1') then
                    fsm_1_next_state <= S_SENDING;
                    CNT_EN <= '1';
                else
                    READY_FOR_DATA <= '1';
                    CNT_RST <= '1';
                end if;
                ----------------------------------------
            when S_SENDING =>
                CNT_EN <= '1';
                if (BIT_CNT = 0) then
                    RS232_BIT <= '0';
                elsif (BIT_CNT < 9) then
                    RS232_BIT <= TX_DATA(BIT_CNT - 1);
                elsif (BIT_CNT = 9) then
                else
                    fsm_1_next_state <= S_READY;
                    CNT_RST <= '1';
                    READY_FOR_DATA <= '1';
                end if;
                ----------------------------------------
        end case;
    end process;
    
end arch;

