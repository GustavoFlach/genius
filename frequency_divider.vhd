library ieee;
use ieee.std_logic_1164.all;

entity frequency_divider is
    generic (
        clock_factor: integer
    );
    port (
        clock: in std_logic;
        clock_enable: out std_logic
    );
end entity;

architecture behavior of frequency_divider is

    signal count: integer range 0 to clock_factor-1 := 0;

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (count < clock_factor-1) then
                count <= count + 1;
            else
                count <= 0;
            end if;
        end if;
    end process;

    clock_enable <= '1' when count = clock_factor-1 else '0';

end architecture;
