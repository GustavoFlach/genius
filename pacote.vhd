library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pacote is

type states is (idle, print, dly, waiting, upack, dbc, downack, nextlvl, gg, ff); -- Estados da máquina
	type score is array (3 downto 0) of std_logic_vector (6 downto 0); -- Arranjo da pontuação
	type sequence is array (14 downto 0) of std_logic_vector (3 downto 0); -- Arranjo de uma sequência
	function max(x: integer; y: integer) return integer;
    function char_to_ssd(c: character) return std_logic_vector;
	
	-- Constantes que definem as sequências possiveis de 14 cores para o jogo
	constant seq0: sequence := ("0010","0001","0010","0100","1000","0100","0010",
	"0001","0010","0100","1000","0100","0010","0001", "0000");
	
								 
end pacote;


package body pacote is

function max(x: integer; y: integer) return integer is
    begin
        if x > y then
            return x;
        else
            return y;
        end if;
    end function;

    function char_to_ssd(c: character) return std_logic_vector is
    begin
        case c is
            when '0' =>
                return "1111110";
            when '1' =>
                return "0110000";
            when '2' =>
                return "1101101";
            when '3' =>
                return "1111001";
            when '4' =>
                return "0110011";
            when '5' =>
                return "1011011";
            when '6' =>
                return "1011111";
            when '7' =>
                return "1110000";
            when '8' =>
                return "1111111";
            when '9' =>
                return "1111011";
            when 'A' =>
                return "1110111";
				when 'B' =>
                return "0011111";	 
            when 'C' =>
                return "1001110";
				when 'D' =>
                return "0111101";	 
            when 'E' =>
                return "1001111";
				when 'F' =>
                return "1000111";	 
            when 'G' =>
                return "1011110";
            when 'H' =>
                return "0110111";
            when 'I' =>
                return "0110000";
            when 'J' =>
                return "0111000";
            when 'L' =>
                return "0001110";
				when 'M' =>
                return "0010101";	 
				when 'N' =>
                return "1110110";
            when 'O' =>
                return "1111110";
            when 'P' =>
                return "1100111";
            when 'R' =>
                return "0000101";
            when 'S' =>
                return "1011011";
            when 'T' =>
                return "0001111";
				when 'U' =>
                return "0111110";
            when 'V' =>
                return "0111110";
				when '-' =>
                return "0000001";	 
            when others =>
                return "0000000";
        end case;
    end function;
 
end pacote;
