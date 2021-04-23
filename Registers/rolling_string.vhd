-- ==============================================================================
-- DESCRIPTION:
-- It provides characters extracted from a string. 
-- A new character is popped out only if the "read" address remain on the STRING_REG_ADDR_g
-- ------------------------------------------
-- File        : rolling_string.vhd
-- Revision    : 1.0
-- Author      : M. Casti (IIT)
-- Date        : 30/10/2019
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  30/10/2019 - M. Casti (IIT)
-- - Initial revision
-- ==============================================================================
-- WRITING STYLE 
-- 
-- INPUTs:    UPPERCASE followed by "_i"
-- OUTPUTs:   UPPERCASE followed by "_o"
-- BUFFERs:   UPPERCASE followed by "_b"
-- CONSTANTs: UPPERCASE followed by "_c"
-- GENERICs:  UPPERCASE followed by "_g"
-- 
-- ==============================================================================


library ieee;
	use ieee.std_logic_1164.all;
	use ieee. std_logic_arith.all;
	use ieee.std_logic_unsigned.all;

entity rolling_string is
  generic (
    ROLLING_STRING_g    : string                 := "DEFAULT STRING";
    BUS_ADDR_WIDTH_g    : natural range 0 to 8   :=  8;    
    STRING_REG_ADDR_g   : natural range 0 to 255 :=  0
    );
  port ( 
    CLK_i           : in std_logic;
    RST_N_i         : in std_logic;
    BUS_ADDR_i      : in std_logic_vector (BUS_ADDR_WIDTH_g-1 downto 0);
    CHAR_OUT_o      : out std_logic_vector (7 downto 0);
    RD_i            : in std_logic
    );
end rolling_string;

architecture Behavioral of rolling_string is

constant string_reg_addr : std_logic_vector (BUS_ADDR_WIDTH_g-1 downto 0) := conv_std_logic_vector(STRING_REG_ADDR_g,BUS_ADDR_WIDTH_g);
constant FULL_ROLLIN_STRING_c : string := stx & ROLLING_STRING_g & etx;

begin

ROLLING_proc : process (CLK_i, RST_N_i)
variable char_pointer  : natural range 1 to FULL_ROLLIN_STRING_c'length + 1;
begin
  if (RST_N_i = '0') then
    char_pointer := 1;
  elsif rising_edge(CLK_i) then
    if (RD_i = '1') then
      if (BUS_ADDR_i = string_reg_addr) then
        char_pointer := char_pointer + 1;
      else
        char_pointer := 1;
      end if;
    end if;
-- CHAR_OUT_o <= CONV_STD_LOGIC_VECTOR(char_pointer,8);
CHAR_OUT_o <= CONV_STD_LOGIC_VECTOR(character'pos(FULL_ROLLIN_STRING_c(char_pointer)),8);  
end if;

end process ROLLING_proc;

end Behavioral;
