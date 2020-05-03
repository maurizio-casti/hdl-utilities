-- ==============================================================================
-- DESCRIPTION:
-- Provides clock enables to FPGA fabric
-- ------------------------------------------
-- File        : time_machine.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 04/05/2020
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  04/05/2020 - M. Casti
-- - Initial release
-- 
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
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity time_machine is
generic ( 
  CLK_PERIOD_g           : integer    := 10;   -- Main Clock period
  SIM_TIME_COMPRESSION_g : in boolean := FALSE -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  );
port (
  -- Clock in port
  CLK_i              : in  std_logic;   -- Input clock @ 50 MHz,
  RST_N_i            : in  std_logic;   -- Asynchronous active low reset
  
  -- Output ports for generated clock enables
  EN200NS_o           : out std_logic;	-- Clock enable every 200 ns
  EN1US_o             : out std_logic;	-- Clock enable every 1 us
  EN10US_o            : out std_logic;	-- Clock enable every 10 us
  EN100US_o           : out std_logic;	-- Clock enable every 100 us
  EN1MS_o             : out std_logic 	-- Clock enable every 1 ms
  );
end time_machine;

architecture Behavioral of time_machine is

-- Internal signals
signal en200ns_cnt    : std_logic_vector(4 downto 0) := (others => '0');  
signal en200ns_cnt_tc : std_logic;  
signal p_en200ns      : std_logic;  
signal en200ns        : std_logic;	

signal en1us_cnt      : std_logic_vector(2 downto 0) := (others => '0');  
signal en1us_cnt_tc   : std_logic;  
signal p_en1us        : std_logic;  
signal en1us          : std_logic;	

signal en10us_cnt     : std_logic_vector(3 downto 0) := (others => '0');  
signal en10us_cnt_tc  : std_logic;  
signal p_en10us       : std_logic;  
signal en10us         : std_logic;	

signal en100us_cnt    : std_logic_vector(3 downto 0) := (others => '0');  
signal en100us_cnt_tc : std_logic;  
signal p_en100us      : std_logic;  
signal en100us        : std_logic;	

signal en1ms_cnt      : std_logic_vector(3 downto 0) := (others => '0');  
signal en1ms_cnt_tc   : std_logic;  
signal p_en1ms        : std_logic;  
signal en1ms          : std_logic;	

-- Calculation of constants used in generation of Enables
function scale_value (a : natural; b : boolean) return natural is
variable temp : natural;
begin
  case a is                                                               --                                                                              FALSE      TRUE
    when 0 => if b then temp := 7; else temp := ((200/CLK_PERIOD_g)-1);  end if; return temp;  --   en200ns_period = CLK_i_period * (temp + 1)    -->    200 ns     80 ns
    when 1 => if b then temp := 4; else temp :=                      4;  end if; return temp;  --   en1us_period   = en200ns_period * (temp + 1)  -->      1 us    400 ns
    when 2 => if b then temp := 1; else temp :=                      9;  end if; return temp;  --   en10us_period  = en1us_period * (temp + 1)    -->     10 us    800 ns
    when 3 => if b then temp := 1; else temp :=                      9;  end if; return temp;  --   en100us_period = en10us_period * (temp + 1)   -->    100 us   1600 ns
    when 4 => if b then temp := 1; else temp :=                      9;  end if; return temp;  --   en1ms_period   = en100us_period * (temp + 1)  -->      1 ms   3200 ns
    when others => report "Configuration not supported" 
	  severity failure; 
		return 0;
  end case;
end function;

constant EN200NS_CONSTANT_c : natural := scale_value(0, SIM_TIME_COMPRESSION_g);
constant EN1US_CONSTANT_c   : natural := scale_value(1, SIM_TIME_COMPRESSION_g);
constant EN10US_CONSTANT_c  : natural := scale_value(2, SIM_TIME_COMPRESSION_g);
constant EN100US_CONSTANT_c : natural := scale_value(3, SIM_TIME_COMPRESSION_g);
constant EN1MS_CONSTANT_c   : natural := scale_value(4, SIM_TIME_COMPRESSION_g);

begin



-- ---------------------------------------------------------------------------------------------------
-- CLOCK ENABLES



-- Enable @ 200 ns
en200ns_cnt_tc <= '1' when (en200ns_cnt = conv_std_logic_vector(EN200NS_CONSTANT_c, en200ns_cnt'length)) else '0'; 
process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en200ns_cnt <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (en200ns_cnt_tc = '1') then
      en200ns_cnt <= (others => '0');  
    else 
      en200ns_cnt <= en200ns_cnt + 1;
    end if;
  end if;
end process; 

p_en200ns <= en200ns_cnt_tc;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en200ns <= '0';
  elsif rising_edge(CLK_i) then
    en200ns <= p_en200ns;
  end if;
end process;  


-- Enable @ 1 us
en1us_cnt_tc <= '1' when (en1us_cnt = conv_std_logic_vector(EN1US_CONSTANT_c ,en1us_cnt'length)) else '0';
process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en1us_cnt <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (p_en200ns = '1') then
      if (en1us_cnt_tc = '1') then 
        en1us_cnt <= (others => '0');  
      else 
        en1us_cnt <= en1us_cnt + 1;
      end if;
	end if;
  end if;
end process; 

p_en1us <= en1us_cnt_tc and p_en200ns;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en1us <= '0';
  elsif rising_edge(CLK_i) then
    en1us <= p_en1us;
  end if;
end process;  
  

-- Enable @ 10 us
en10us_cnt_tc <= '1' when (en10us_cnt = conv_std_logic_vector(EN10US_CONSTANT_c ,en10us_cnt'length)) else '0';
process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en10us_cnt <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (p_en1us = '1') then
      if (en10us_cnt_tc = '1') then 
        en10us_cnt <= (others => '0');  
      else 
        en10us_cnt <= en10us_cnt + 1;
      end if;
	end if;
  end if;
end process; 

p_en10us <= en10us_cnt_tc and p_en1us;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en10us <= '0';
  elsif rising_edge(CLK_i) then
    en10us <= p_en10us;
  end if;
end process;  
  

-- Enable @ 100 us
en100us_cnt_tc <= '1' when (en100us_cnt = conv_std_logic_vector(EN100US_CONSTANT_c ,en100us_cnt'length)) else '0';
process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en100us_cnt <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (p_en10us = '1') then
      if (en100us_cnt_tc = '1') then 
        en100us_cnt <= (others => '0');  
      else 
        en100us_cnt <= en100us_cnt + 1;
      end if;
	end if;
  end if;
end process; 

p_en100us <= en100us_cnt_tc and p_en10us;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en100us <= '0';
  elsif rising_edge(CLK_i) then
    en100us <= p_en100us;
  end if;
end process;  
  
  
-- Enable @ 1  ms
en1ms_cnt_tc <= '1' when (en1ms_cnt = conv_std_logic_vector(EN1MS_CONSTANT_c, en1ms_cnt'length)) else '0';
process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en1ms_cnt <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (p_en100us = '1') then
      if (en1ms_cnt_tc = '1') then 
        en1ms_cnt <= (others => '0');  
      else 
        en1ms_cnt <= en1ms_cnt + 1;
      end if;
	end if;
  end if;
end process; 

p_en1ms <= en1ms_cnt_tc and p_en100us;

process(CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    en1ms <= '0';
  elsif rising_edge(CLK_i) then
    en1ms <= p_en1ms;
  end if;
end process;  
  


-- ---------------------------------------------------------------------------------------------------
-- OUTPUTS

EN200NS_o       <= en200ns;
EN1US_o         <= en1us;
EN10US_o        <= en10us;
EN100US_o       <= en100us;
EN1MS_o         <= en1ms;
  
end Behavioral;

