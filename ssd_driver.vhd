library ieee;
use ieee.std_logic_1164.all;

entity ssd_driver is
    generic (
        interval: integer
    );
    port (
        clock: in std_logic;
        clock_enable: in std_logic;
        x0, x1, x2, x3: in std_logic_vector(0 to 6);
        y: out std_logic_vector(0 to 7);
        s: out std_logic_vector(0 to 3)
    );
end entity;

architecture behavior of ssd_driver is

    type state is (zero, one, two, three);

    signal present_state: state := zero;
    signal next_state: state;

begin

    process (clock)
        variable count: integer range 0 to interval-1 := 0;
    begin
        if (clock'event and clock = '1') then
            if (clock_enable = '1') then
                if (count < interval-1) then
                    count := count + 1;
                else
                    count := 0;
                    present_state <= next_state;
                end if;
            end if;
        end if;
    end process;

    process (present_state)
    begin
        case present_state is
            when zero =>
                next_state <= one;
            when one =>
                next_state <= two;
            when two =>
                next_state <= three;
            when three =>
                next_state <= zero;
        end case;
    end process;

    process (present_state, x0, x1, x2, x3)
    begin
        case present_state is
            when zero =>
                y(0 to 6) <= not x0; y(7) <= '1';
                s <= "0111";
            when one =>
                y(0 to 6) <= not x1; y(7) <= '1';
                s <= "1011";
            when two =>
                y(0 to 6) <= not x2; y(7) <= '1';
                s <= "1101";
            when three =>
                y(0 to 6) <= not x3; y(7) <= '1';
                s <= "1110";
        end case;
    end process;

end architecture;
