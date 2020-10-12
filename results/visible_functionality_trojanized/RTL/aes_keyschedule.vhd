library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

----------------------------------------------
-- VHDL code generated by MHDL v0.1.3.4
----------------------------------------------

entity AESKeySchedule is
    port (
        current_key : in  std_logic_vector (127 downto 0);
        counter     : in  unsigned(3 downto 0);
        next_key    : out std_logic_vector (127 downto 0)
    );
end AESKeySchedule;

architecture arch of AESKeySchedule is
    signal g_after_sbox  : std_logic_vector (31 downto 0);
    signal g_after_shift : std_logic_vector (31 downto 0);
    signal g_func_input  : std_logic_vector (31 downto 0);
    signal g_func_output : std_logic_vector (31 downto 0);
    signal rcon          : std_logic_vector (7 downto 0);
    signal w0            : std_logic_vector (31 downto 0);
    signal w1            : std_logic_vector (31 downto 0);
    signal w2            : std_logic_vector (31 downto 0);
    signal w3            : std_logic_vector (31 downto 0);
begin
    process(counter)
    begin
        case counter is
            when "0000" =>
                rcon <= "00000001";
            when "0001" =>
                rcon <= "00000010";
            when "0010" =>
                rcon <= "00000100";
            when "0011" =>
                rcon <= "00001000";
            when "0100" =>
                rcon <= "00010000";
            when "0101" =>
                rcon <= "00100000";
            when "0110" =>
                rcon <= "01000000";
            when "0111" =>
                rcon <= "10000000";
            when "1000" =>
                rcon <= "00011011";
            when "1001" =>
                rcon <= "00110110";
            when others =>
                rcon <= "00000000";
        end case;
    end process;
    
    g_func_input <= current_key(31 downto 0);
    g_after_shift(7 downto 0) <= g_func_input(31 downto 24);
    g_after_shift(15 downto 8) <= g_func_input(7 downto 0);
    g_after_shift(23 downto 16) <= g_func_input(15 downto 8);
    g_after_shift(31 downto 24) <= g_func_input(23 downto 16);
    gen : for i in 0 to 3 generate sbox : entity work . AES_Sbox port map (g_after_shift((i + 1) * 8 - 1 downto i * 8), g_after_sbox((i + 1) * 8 - 1 downto i * 8));
end generate;

g_func_output(31 downto 24) <= rcon xor g_after_sbox(31 downto 24);
g_func_output(23 downto 0) <= g_after_sbox(23 downto 0);
w0 <= current_key(127 downto 96) xor g_func_output;
w1 <= w0 xor current_key(95 downto 64);
w2 <= w1 xor current_key(63 downto 32);
w3 <= w2 xor current_key(31 downto 0);
next_key <= w0 & w1 & w2 & w3;
end arch;
