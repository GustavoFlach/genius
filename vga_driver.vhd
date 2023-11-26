library ieee;
use ieee.std_logic_1164.all;

entity vga_driver is
    generic (
        h_bp: integer; -- horizontal back porch
        h_aw: integer; -- horizontal active window
        h_fp: integer; -- horizontal front porch
        h_sp: integer; -- horizontal sync pulse
        v_bp: integer; -- vertical back porch
        v_aw: integer; -- vertical active window
        v_fp: integer; -- vertical front porch
        v_sp: integer; -- vertical sync pulse
        x_0: integer; -- x coordinate of top left of drawing
        y_0: integer; -- y coordinate of top left of drawing
        s_l: integer; -- length of each segment of drawing
        s_w: integer -- width of each segment of drawing
        
    );
    port (
        clock: in std_logic;
        clock_enable: in std_logic;
        x: in std_logic_vector(0 to 16);
        r: out std_logic_vector(2 downto 0);
        g: out std_logic_vector(2 downto 0);
        b: out std_logic_vector(1 downto 0);
        h_sync: out std_logic;
        v_sync: out std_logic;
		 signal r_foreground: std_logic_vector(2 downto 0);
       signal g_foreground: std_logic_vector(2 downto 0);
       signal b_foreground: std_logic_vector(1 downto 0);
       signal r_background: std_logic_vector(2 downto 0);
       signal g_background: std_logic_vector(2 downto 0);
       signal b_background: std_logic_vector(1 downto 0)
    );
end entity;

architecture behavior of vga_driver is

    constant h_a: integer := h_bp;
    constant h_b: integer := h_bp + h_aw;
    constant h_c: integer := h_bp + h_aw + h_fp;
    constant h_d: integer := h_bp + h_aw + h_fp + h_sp;
    constant v_a: integer := v_bp;
    constant v_b: integer := v_bp + v_aw;
    constant v_c: integer := v_bp + v_aw + v_fp;
    constant v_d: integer := v_bp + v_aw + v_fp + v_sp;

    signal h_count: integer range 0 to h_d-1 := 0;
    signal v_count: integer range 0 to v_d-1 := 0;

    signal next_r: std_logic_vector(2 downto 0);
    signal next_g: std_logic_vector(2 downto 0);
    signal next_b: std_logic_vector(1 downto 0);
    signal next_h_sync: std_logic;
    signal next_v_sync: std_logic;

begin

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (clock_enable = '1') then
                if (h_count < h_d-1) then
                    h_count <= h_count + 1;
                else
                    h_count <= 0;
                    if (v_count < v_d-1) then
                        v_count <= v_count + 1;
                    else
                        v_count <= 0;
                 end if;
                end if;
            end if;
        end if;
    end process;

    process (h_count, v_count, x, r_foreground, g_foreground, b_foreground, r_background, g_background, b_background)
    begin
        if (
            h_a <= h_count and
            h_count < h_b and
            v_a <= v_count and
            v_count < v_b
        ) then
            -- active area
            if (
                (-- parte de cima do P
    x(15) = '1' and
    80 <= h_count and -- x inicial
    h_count < 160 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da ponta P
    x(15) = '1' and
    130 <= h_count and -- x inicial
    h_count < 160 and -- x final
    230 <= v_count and -- y inicial
    v_count < 250-- y final
) or
(-- horizontal debaixo P
    x(15) = '1' and
    80 <= h_count and -- x inicial
    h_count < 160 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- vertical do corpo P
    x(15) = '1' and
    80 <= h_count and -- x inicial
    h_count < 110 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- parte de cima do A
    x(15) = '1' and
    180 <= h_count and -- x inicial
    h_count < 260 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda A
    x(15) = '1' and
    180 <= h_count and -- x inicial
    h_count < 210 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita A
    x(15) = '1' and
    230 <= h_count and -- x inicial
    h_count < 260 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal debaixo A
    x(15) = '1' and
    180 <= h_count and -- x inicial
    h_count < 260 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- parte de cima do R
    x(15) = '1' and
    280 <= h_count and -- x inicial
    h_count < 360 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda R
    x(15) = '1' and
    280 <= h_count and -- x inicial
    h_count < 310 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita R
    x(15) = '1' and
    330 <= h_count and -- x inicial
    h_count < 360 and -- x final
    230 <= v_count and -- y inicial
    v_count < 250-- y final
) or
(-- primeiro quadrado debaixo R
    x(15) = '1' and
    310 <= h_count and -- x inicial
    h_count < 330 and -- x final
    280 <= v_count and -- y inicial
    v_count < 315-- y final
) or
(-- segundo quadrado debaixo R
    x(15) = '1' and
    330 <= h_count and -- x inicial
    h_count < 360 and -- x final
    315 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal debaixo R
    x(15) = '1' and
    280 <= h_count and -- x inicial
    h_count < 360 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- parte de cima do A
    x(15) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda A
    x(15) = '1' and
    380 <= h_count and -- x inicial
    h_count < 410 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita A
    x(15) = '1' and
    430 <= h_count and -- x inicial
    h_count < 460 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal debaixo A
    x(15) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- parte de cima do B
    x(15) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda B
    x(15) = '1' and
    480 <= h_count and -- x inicial
    h_count < 510 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita B
    x(15) = '1' and
    530 <= h_count and -- x inicial
    h_count < 560 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal do meio B
    x(15) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- horizontal debaixo B
    x(15) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    320 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- parte de cima do E
    x(15) = '1' and
    580 <= h_count and -- x inicial
    h_count < 660 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda E
    x(15) = '1' and
    580 <= h_count and -- x inicial
    h_count < 610 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal do meio E
    x(15) = '1' and
    580 <= h_count and -- x inicial
    h_count < 660 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- horizontal debaixo E
    x(15) = '1' and
    580 <= h_count and -- x inicial
    h_count < 660 and -- x final
    320 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da esquerda N
    x(15) = '1' and
    680 <= h_count and -- x inicial
    h_count < 700 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita N
    x(15) = '1' and
    740 <= h_count and -- x inicial
    h_count < 760 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- primeiro quadrado do meio N
    x(15) = '1' and
    700 <= h_count and -- x inicial
    h_count < 720 and -- x final
    220 <= v_count and -- y inicial
    v_count < 290-- y final
) or
(-- segundo quadrado do meio N
    x(15) = '1' and
    720 <= h_count and -- x inicial
    h_count < 740 and -- x final
    260 <= v_count and -- y inicial
    v_count < 330-- y final
) or
(-- parte de cima do S
    x(15) = '1' and
    780 <= h_count and -- x inicial
    h_count < 860 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- horizontal do meio S
    x(15) = '1' and
    780 <= h_count and -- x inicial
    h_count < 860 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- vertical da esquerda S
    x(15) = '1' and
    780 <= h_count and -- x inicial
    h_count < 810 and -- x final
    200 <= v_count and -- y inicial
    v_count < 280-- y final
)or
(-- vertical da direita S
    x(15) = '1' and
    830 <= h_count and -- x inicial
    h_count < 860 and -- x final
    280 <= v_count and -- y inicial
    v_count < 330-- y final
)or
(-- horizontal do meio S
    x(15) = '1' and
    780 <= h_count and -- x inicial
    h_count < 860 and -- x final
    300 <= v_count and -- y inicial
    v_count < 350-- y final
)
-----------------------------------------------------------------
or
(-- parte de cima do F
    x(16) = '1' and
    350 <= h_count and -- x inicial
    h_count < 430 and -- x final
    20 <= v_count and -- y inicial
    v_count < 50-- y final
) or
(-- horizontal debaixo F
    x(16) = '1' and
    350 <= h_count and -- x inicial
    h_count < 430 and -- x final
    70 <= v_count and -- y inicial
    v_count < 100-- y final
) or
(-- vertical do corpo F
    x(16) = '1' and
    350 <= h_count and -- x inicial
    h_count < 380 and -- x final
    20 <= v_count and -- y inicial
    v_count < 170-- y final
)
or
(-- vertical do corpo i
    x(16) = '1' and
    450 <= h_count and -- x inicial
    h_count < 480 and -- x final
    20 <= v_count and -- y inicial
    v_count < 170-- y final
)or
(-- vertical da esquerda M
    x(16) = '1' and
    500 <= h_count and -- x inicial
    h_count < 520 and -- x final
    20 <= v_count and -- y inicial
    v_count < 170-- y final
) or
(-- vertical da direita M
    x(16) = '1' and
    560 <= h_count and -- x inicial
    h_count < 580 and -- x final
    20 <= v_count and -- y inicial
    v_count < 170-- y final
) or
(-- primeiro quadrado do meio M
    x(16) = '1' and
    520 <= h_count and -- x inicial
    h_count < 530 and -- x final
    20 <= v_count and -- y inicial
    v_count < 50-- y final
) or
(-- segundo quadrado do meio M
    x(16) = '1' and
    550 <= h_count and -- x inicial
    h_count < 560 and -- x final
    20 <= v_count and -- y inicial
    v_count < 50-- y final
)
or
(-- meio quadrado do meio M
    x(16) = '1' and
    530 <= h_count and -- x inicial
    h_count < 550 and -- x final
    35 <= v_count and -- y inicial
    v_count < 70-- y final
)or
(-- parte de cima do D
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda D
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 410 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- vertical da direita D
    x(16) = '1' and
    430 <= h_count and -- x inicial
    h_count < 460 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal debaixo D
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    320 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- parte de cima do E
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    200 <= v_count and -- y inicial
    v_count < 230-- y final
) or
(-- vertical da esquerda E
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 510 and -- x final
    200 <= v_count and -- y inicial
    v_count < 350-- y final
) or
(-- horizontal do meio E
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    250 <= v_count and -- y inicial
    v_count < 280-- y final
) or
(-- horizontal debaixo E
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    320 <= v_count and -- y inicial
    v_count < 350-- y final
)or
(-- vertical J
    x(16) = '1' and
    330 <= h_count and -- x inicial
    h_count < 360 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
)or
(-- horizontal J
    x(16) = '1' and
    280 <= h_count and -- x inicial
    h_count < 360 and -- x final
    500 <= v_count and -- y inicial
    v_count < 530-- y final
)or
(-- parte de cima do O
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    380 <= v_count and -- y inicial
    v_count < 410-- y final
) or
(-- vertical da esquerda O
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 410 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
) or
(-- vertical da direita O
    x(16) = '1' and
    430 <= h_count and -- x inicial
    h_count < 460 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
) or
(-- horizontal debaixo O
    x(16) = '1' and
    380 <= h_count and -- x inicial
    h_count < 460 and -- x final
    500 <= v_count and -- y inicial
    v_count < 530-- y final
)or
(-- parte de cima do G
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    380 <= v_count and -- y inicial
    v_count < 410-- y final
) or
(-- vertical da esquerda G
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 510 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
) or
(-- vertical da direita G
    x(16) = '1' and
    530 <= h_count and -- x inicial
    h_count < 560 and -- x final
    460 <= v_count and -- y inicial
    v_count < 530-- y final
) or
(-- horizontal do meio G
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    430 <= v_count and -- y inicial
    v_count < 460-- y final
) or
(-- horizontal debaixo G
    x(16) = '1' and
    480 <= h_count and -- x inicial
    h_count < 560 and -- x final
    500 <= v_count and -- y inicial
    v_count < 530-- y final
)or
(-- parte de cima do O
    x(16) = '1' and
    580 <= h_count and -- x inicial
    h_count < 660 and -- x final
    380 <= v_count and -- y inicial
    v_count < 410-- y final
) or
(-- vertical da esquerda O
    x(16) = '1' and
    580 <= h_count and -- x inicial
    h_count < 610 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
)or
(-- vertical da direita O
    x(16) = '1' and
    630 <= h_count and -- x inicial
    h_count < 660 and -- x final
    380 <= v_count and -- y inicial
    v_count < 530-- y final
)  or
(-- horizontal debaixo O
    x(16) = '1' and
    580 <= h_count and -- x inicial
    h_count < 660 and -- x final
    500 <= v_count and -- y inicial
    v_count < 530-- y final
)
----------------------------------------------------------------------00
or(-- parte de cima do 0 esquerda
    x(1) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(1) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(1) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(1) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)

or(-- parte de cima do 0 direita
    x(1) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 direita
    x(1) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 direita
    x(1) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 direita
    x(1) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
---------------------------------------------------------------01
or(-- parte de cima do 0 esquerda
    x(2) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(2) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(2) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(2) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita i direita
    x(2) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
----------------------------------------------------------------------02
or(-- parte de cima do 0 esquerda
    x(3) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(3) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(3) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(3) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 2 direita
    x(3) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 2 direita
    x(3) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 2 direita
    x(3) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 2 direita
    x(3) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    105 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 2 direita
    x(3) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 95-- y final
)
----------------------------------------------------------------------03
or(-- parte de cima do 0 esquerda
    x(4) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(4) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(4) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(4) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 3 direita
    x(4) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 3 direita
    x(4) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 3 direita
    x(4) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 3 direita
    x(4) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
----------------------------------------------------------------------04
or(-- parte de cima do 0 esquerda
    x(5) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(5) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(5) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(5) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- horizontal do meio 4 direita
    x(5) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)or
(-- vertical da esquerda 4 direita
    x(5) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 105-- y final
)
or
(-- vertical da direita 4 direita
    x(5) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
----------------------------------------------------------------------05
or(-- parte de cima do 0 esquerda
    x(6) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(6) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(6) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(6) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 5 direita
    x(6) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 5 direita
    x(6) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 5 direita
    x(6) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da direita 5 direita
    x(6) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    105 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da esquerda 5 direita
    x(6) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 95-- y final
)
----------------------------------------------------------------------06
or(-- parte de cima do 0 esquerda
    x(7) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(7) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(7) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(7) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 6 direita
    x(7) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 6 direita
    x(7) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 6 direita
    x(7) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da direita 6 direita
    x(7) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    105 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da esquerda 6 direita
    x(7) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)      
--------------------------------------------------07
or(-- parte de cima do 0 esquerda
    x(8) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(8) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(8) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(8) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 7 direita
    x(8) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
)
or
(-- vertical da direita 7 direita
    x(8) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
----------------------------------------------------------08
or(-- parte de cima do 0 esquerda
    x(9) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(9) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(9) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(9) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 8 direita
    x(9) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 8 direita
    x(9) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 8 direita
    x(9) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 8 direita
    x(9) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 8 direita
    x(9) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
----------------------------------------------------------09
or(-- parte de cima do 0 esquerda
    x(10) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 esquerda
    x(10) = '1' and
    80 <= h_count and -- x inicial
    h_count < 100 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 esquerda
    x(10) = '1' and
    80 <= h_count and -- x inicial
    h_count < 85 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 esquerda
    x(10) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 9 direita
    x(10) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 9 direita
    x(10) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 9 direita
    x(10) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 9 direita
    x(10) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 105-- y final
)
or
(-- vertical da direita 9 direita
    x(10) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
--------------------------------------------------10
or
(-- vertical da direita 1 esquerda
    x(11) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)

or(-- parte de cima do 0 direita
    x(11) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal debaixo 0 direita
    x(11) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 0 direita
    x(11) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 0 direita
    x(11) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
------------------------------------------------11
or
(-- vertical da direita 1 esquerda
    x(12) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita i direita
    x(12) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
-----------------------------------------------12
or
(-- vertical da direita 1 esquerda
    x(13) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 2 direita
    x(13) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 2 direita
    x(13) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 2 direita
    x(13) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
) or
(-- vertical da esquerda 2 direita
    x(13) = '1' and
    110 <= h_count and -- x inicial
    h_count < 115 and -- x final
    105 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 2 direita
    x(13) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 95-- y final
)
------------------------------------------------13
or
(-- vertical da direita 1 esquerda
    x(14) = '1' and
    95 <= h_count and -- x inicial
    h_count < 100 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
or(-- parte de cima do 3 direita
    x(14) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 90-- y final
) or
(-- horizontal do meio 3 direita
    x(14) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    95 <= v_count and -- y inicial
    v_count < 105-- y final
)  
or
(-- horizontal debaixo 3 direita
    x(14) = '1' and
    110 <= h_count and -- x inicial
    h_count < 130 and -- x final
    110 <= v_count and -- y inicial
    v_count < 120-- y final
)
or
(-- vertical da direita 3 direita
    x(14) = '1' and
    125 <= h_count and -- x inicial
    h_count < 130 and -- x final
    80 <= v_count and -- y inicial
    v_count < 120-- y final
)
-----------------------------------------------colors
or
(
    x(0) = '1' and
    0 <= h_count and -- x inicial
    h_count < 800 and -- x final
    0 <= v_count and -- y inicial
    v_count < 600-- y final
)
        ) then
                -- foreground
                next_r <= r_foreground;
                next_g <= g_foreground;
                next_b <= b_foreground;
            else
                -- background
                next_r <= r_background;
                next_g <= g_background;
                next_b <= b_background;
            end if;
        else
            -- blanking area
            next_r <= "000";
            next_g <= "000";
            next_b <= "00";
        end if;

        if (h_c <= h_count) then
            next_h_sync <= '0';
        else
            next_h_sync <= '1';
        end if;

        if (v_c <= v_count) then
            next_v_sync <= '0';
        else
            next_v_sync <= '1';
        end if;
    end process;

    process (clock)
    begin
        if (clock'event and clock = '1') then
            if (clock_enable = '1') then
                r <= next_r;
                g <= next_g;
                b <= next_b;
                h_sync <= next_h_sync;
                v_sync <= next_v_sync;
            end if;
        end if;
    end process;

end architecture;