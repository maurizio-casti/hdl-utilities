--------------------------------------------------------------------------------
-- Company      : IIT 
-- Engineer     : Maurizio Casti
--------------------------------------------------------------------------------
-- Description  : Provides some RESET signal 
--==============================================================================
-- PRESENT REVISION
--==============================================================================
-- File         : reset_machine.vhd
-- Revision     : 1.0
-- Author       : M. Casti
-- Date         : 21/08/2019
 --==============================================================================
-- Revision history :
--
-- Rev 2.0      : 12/11/2021  (M. Casti - IIT)
-- - Redesign
--
-- Rev 1.0      : 21/08/2019  
-- - Initial revision (M. Casti - IIT)
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

library unisim;
   use unisim.vcomponents.all;
----------------------------------------------------------------------------------

entity reset_machine is
  generic (
    CLR_POLARITY_g           : string := "HIGH";               -- Active "HIGH" or "LOW"
    ARST_LONG_PERSISTANCE_g  : integer range 0 to 31 := 16;    -- Persistance of Power-On reset (clock pulses)
    HAS_POR_g                : boolean := TRUE                 -- If TRUE a Power On Reset is generated  
    );
  port ( 
    CLK_i         : in  std_logic;        -- Input Clock
    MCM_LOCKED_i  : in  std_logic := 'H'; -- Clock locked flag
    CLR_i         : in  std_logic := 'L'; -- Polarity controlled Asyncronous Clear input
  
    -- Reset output
    ARST_o        : out std_logic;        -- Active high asyncronous assertion, syncronous deassertion Reset output
    ARST_N_o      : out std_logic;        -- Active low asyncronous assertion, syncronous deassertion Reset output 
    ARST_LONG_o   : out std_logic;	      -- Active high asyncronous assertion, syncronous deassertion Long Duration Reset output
    ARST_LONG_N_o : out std_logic 	      -- Active low asyncronous assertion, syncronous deassertion Long Duration Reset output 
  );
end reset_machine;

architecture Behavioral of reset_machine is

attribute ASYNC_REG : string;

-- -------------------------------------------------------------------------------------------------------------------------
-- Resets

-- Asynchronous reset with synchronous deassertion
function clr_pol(a : string) return std_logic is
begin
  if    a = "LOW"  then return '0';
  elsif a = "HIGH" then return '1';
  else report "Configuration not supported" severity failure; return '0';
  end if;
end function;

function has_por(a : boolean) return std_logic is
begin
  if    a = FALSE  then return '0';
  elsif a = TRUE then return '1';
  else report "Configuration not supported" severity failure; return '0';
  end if;
end function;

function has_por_vect(a : boolean; b : integer; c : integer) return std_logic_vector is
begin
  if    a = FALSE  then return conv_std_logic_vector(0, c);
  elsif a = TRUE then return conv_std_logic_vector(b, c);
  else report "Configuration not supported" severity failure; return conv_std_logic_vector(0, c);
  end if;
end function;

constant CLR_POL_c    : std_logic := clr_pol(CLR_POLARITY_g); 

signal clear : std_logic;

signal pp_arst, p_arst, arst        : std_logic := has_por(HAS_POR_g);
  attribute ASYNC_REG of pp_arst    : signal is "TRUE";
  attribute ASYNC_REG of p_arst     : signal is "TRUE";
  attribute ASYNC_REG of arst       : signal is "TRUE";
signal pp_arst_n, p_arst_n, arst_n  : std_logic := not has_por(HAS_POR_g);
  attribute ASYNC_REG of pp_arst_n  : signal is "TRUE";
  attribute ASYNC_REG of p_arst_n   : signal is "TRUE";
  attribute ASYNC_REG of arst_n     : signal is "TRUE";

-- Long Reset
signal long_arst_cnt  : std_logic_vector(4 downto 0) := has_por_vect(HAS_POR_g, ARST_LONG_PERSISTANCE_g, 5);
signal long_arst      : std_logic := has_por(HAS_POR_g);
signal long_arst_n    : std_logic := not has_por(HAS_POR_g);

begin

-- ---------------------------------------------------------------------------------------------------
-- RESET DEASSERTION SYNCRONIZATION

clear <= not MCM_LOCKED_i or (CLR_i xnor CLR_POL_c);

process(CLK_i, clear)
begin
  if (clear = '1') then
    pp_arst_n  <= '0';
    p_arst_n   <= '0';
    arst_n     <= '0';
    
    pp_arst    <= '1';
    p_arst     <= '1';
    arst       <= '1';   
    
  elsif rising_edge(CLK_i) then
    pp_arst_n <= '1';
    p_arst_n  <= pp_arst_n;
    arst_n    <= p_arst_n;
 
    pp_arst   <= '0';
    p_arst    <= pp_arst;
    arst      <= p_arst;   
 
  end if;
end process;  



-- ---------------------------------------------------------------------------------------------------
-- LONG RESET

process(CLK_i, arst_n)
begin
  if (arst_n = '0') then
    long_arst_cnt <= conv_std_logic_vector(ARST_LONG_PERSISTANCE_g-1, long_arst_cnt'length);
    long_arst     <= '1';
    long_arst_n   <= '0';  
  elsif rising_edge(CLK_i) then
    if (long_arst_cnt = conv_std_logic_vector(0, long_arst_cnt'length)) then
      long_arst     <= '0';
      long_arst_n   <= '1';
    else
      long_arst_cnt <= long_arst_cnt - 1;
    end if;
  end if;
end process; 


-- ---------------------------------------------------------------------------------------------------
-- OUTPUTs

ARST_o          <= arst;
ARST_N_o        <= arst_n;
ARST_LONG_o     <= long_arst;
ARST_LONG_N_o   <= long_arst_n;

end Behavioral;

