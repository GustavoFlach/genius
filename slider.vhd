library ieee;
use ieee.std_logic_1164.all;

use work.pacote.char_to_ssd;

entity slider is
    generic (
        interval: integer;
        message: string
    );
    port (
        clock: in std_logic;
        clock_enable: in std_logic;
        reset: in std_logic;
        enable: in std_logic;
        x0, x1, x2, x3: out std_logic_vector(0 to 6)
    );
end entity;

architecture behavior of slider is

    type indices_type is array(0 to 3) of integer range 0 to message'length-1;
    signal indices: indices_type;

begin

    process (clock)
        variable count: integer range 0 to interval-1;
    begin
        if (clock'event and clock = '1') then
            if (reset = '1') then
                count := 0;
                for i in 0 to 3 loop
                    indices(i) <= i mod message'length;
                end loop;
            elsif (enable = '1' and clock_enable='1') then
                if (count < interval-1) then
                    count := count + 1;
                else
                    count := 0;
                    indices(0 to 2) <= indices(1 to 3);
                    if (indices(3) < message'length-1) then
                        indices(3) <= indices(3) + 1;
                    else
                        indices(3) <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;

    x0 <= char_to_ssd(message(indices(0)+1));
    x1 <= char_to_ssd(message(indices(1)+1));
    x2 <= char_to_ssd(message(indices(2)+1));
    x3 <= char_to_ssd(message(indices(3)+1));

end architecture;
